# Terraform GCP Data Platform Factory

## TODO
- [ ] Bigtable Clustering
- [ ] Encryption
- [ ] Deletion protection

## Introduction
This module implements a minimal opinionated Data Platform Architecture based on Dataflow resources.

Base Blueprint: [GCS To BigQuery](https://github.com/GoogleCloudPlatform/cloud-foundation-fabric/blob/master/blueprints/data-solutions/gcs-to-bq-with-least-privileges/README.md)

The main components that this is setting up are:

- Cloud Storage (GCS) bucket for the Dataflow pipeline build temporary storage
- Cloud Dataflow pipeline: to build fully managed batch and streaming pipelines to transform data ready for processing in the Data Warehouse using Apache Beam.
- BigQuery dataset and tables: to store the transformed data in and query it using SQL, use it to make reports or begin training machine learning models.
- Bigtable table: to store the transformed data in

## Setup

This solution assumes you already have a project created and set up where you wish to host these resources. If not, and you would like for the project to create a new project as well, please refer to the [github repository](https://github.com/GoogleCloudPlatform/cloud-foundation-fabric/tree/master/blueprints/data-solutions/gcs-to-bq-with-least-privileges) for instructions.

### Prerequisites

* Have an [organization](https://cloud.google.com/resource-manager/docs/creating-managing-organization) set up in Google cloud.
* Have a [billing account](https://cloud.google.com/billing/docs/how-to/manage-billing-account) set up.
* Have an existing [project](https://cloud.google.com/resource-manager/docs/creating-managing-projects) with [billing enabled](https://cloud.google.com/billing/docs/how-to/modify-project), we’ll call this the __service project__.

### Roles & Permissions

In order to spin up this architecture, you will need to be a user with the [IAM](https://cloud.google.com/iam) role on the existing project:
 - bigtable.appProfiles.get
 - bigtable.appProfiles.list
 - bigtable.clusters.get
 - bigtable.clusters.list
 - bigtable.instances.get
 - bigtable.instances.list
 - bigtable.locations.list
 - resourcemanager.projects.get
 - bigtable.clusters.create
 - bigtable.instances.create
 - bigtable.clusters.update
 - bigtable.instances.update
 - bigtable.appProfiles.create
 - bigtable.appProfiles.delete
 - bigtable.appProfiles.update
 - bigtable.clusters.delete
 - bigtable.instances.delete
 - roles/dataflow.admin
 - bigquery.bireservations.*
 - bigquery.capacityCommitments.*
 - bigquery.config.*
 - bigquery.connections.*
 - bigquery.dataPolicies.create
 - bigquery.dataPolicies.delete
 - bigquery.dataPolicies.get
 - bigquery.dataPolicies.getIamPolicy
 - bigquery.dataPolicies.list
 - bigquery.dataPolicies.setIamPolicy
 - bigquery.dataPolicies.update
 - bigquery.datasets.*
 - bigquery.models.*
 - bigquery.readsessions.*
 - bigquery.reservationAssignments.*
 - bigquery.reservations.*
 - bigquery.routines.*
 - bigquery.rowAccessPolicies.create
 - bigquery.rowAccessPolicies.delete
 - bigquery.rowAccessPolicies.getIamPolicy
 - bigquery.rowAccessPolicies.list
 - bigquery.rowAccessPolicies.overrideTimeTravelRestrictions
 - bigquery.rowAccessPolicies.setIamPolicy
 - bigquery.rowAccessPolicies.update
 - bigquery.savedqueries.*
 - bigquery.tables.*
 - resourcemanager.projects.get
 - resourcemanager.projects.list

__Note__: To grant a user a role, take a look at the [Granting and Revoking Access](https://cloud.google.com/iam/docs/granting-changing-revoking-access#grant-single-role) documentation.

## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_big_lake_dataset"></a> [big\_lake\_dataset](#module\_big\_lake\_dataset) | ../../../cloud-foundation-fabric/modules/bigquery-dataset | n/a |
| <a name="module_bigtable-instance"></a> [bigtable-instance](#module\_bigtable-instance) | ../../../cloud-foundation-fabric/modules/bigtable-instance | n/a |
| <a name="module_gcs-df-tmp"></a> [gcs-df-tmp](#module\_gcs-df-tmp) | ../../../cloud-foundation-fabric/modules/gcs | n/a |

## Resources

| Name | Type |
|------|------|
| [google_dataflow_job.big_lake_job](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/dataflow_job) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_prefix"></a> [prefix](#input\_prefix) | Prefix used for resource names. | `string` | n/a | yes |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | Project ID where the data Platform is hosted | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | Region used for regional resources. | `string` | `"europe-west1"` | no |
| <a name="input_service_config"></a> [service\_config](#input\_service\_config) | Data Platform service configuration. | <pre>object({<br>    dataflow = optional(object({<br>      template_path	= string<br>      worker_sa		= string<br>      network		= string<br>      subnetwork	= string<br>      machine_type	= string<br>      parameters	= optional(map(string))<br>    }), null)<br>    bigquery = optional(object({<br>      tables = map(object({<br>        deletion_protection      = optional(bool)<br>        description              = optional(string, "Terraform managed.")<br>        friendly_name            = optional(string)<br>        labels                   = optional(map(string), {})<br>        require_partition_filter = optional(bool)<br>        schema                   = optional(string)<br>        external_data_configuration = optional(object({<br>          autodetect                = bool<br>          source_uris               = list(string)<br>          avro_logical_types        = optional(bool)<br>          compression               = optional(string)<br>          connection_id             = optional(string)<br>          file_set_spec_type        = optional(string)<br>          ignore_unknown_values     = optional(bool)<br>          metadata_cache_mode       = optional(string)<br>          object_metadata           = optional(string)<br>          json_options_encoding     = optional(string)<br>          reference_file_schema_uri = optional(string)<br>          schema                    = optional(string)<br>          source_format             = optional(string)<br>          max_bad_records           = optional(number)<br>          csv_options = optional(object({<br>            quote                 = string<br>            allow_jagged_rows     = optional(bool)<br>            allow_quoted_newlines = optional(bool)<br>            encoding              = optional(string)<br>            field_delimiter       = optional(string)<br>            skip_leading_rows     = optional(number)<br>          }))<br>          google_sheets_options = optional(object({<br>            range             = optional(string)<br>            skip_leading_rows = optional(number)<br>          }))<br>          hive_partitioning_options = optional(object({<br>            mode                     = optional(string)<br>            require_partition_filter = optional(bool)<br>            source_uri_prefix        = optional(string)<br>          }))<br>          parquet_options = optional(object({<br>            enum_as_string        = optional(bool)<br>            enable_list_inference = optional(bool)<br>          }))<br>    <br>        }))<br>        options = optional(object({<br>          clustering      = optional(list(string))<br>          encryption_key  = optional(string)<br>          expiration_time = optional(number)<br>          max_staleness   = optional(string)<br>        }), {})<br>        partitioning = optional(object({<br>          field = optional(string)<br>          range = optional(object({<br>            end      = number<br>            interval = number<br>            start    = number<br>          }))<br>          time = optional(object({<br>            type          = string<br>            expiration_ms = optional(number)<br>            field         = optional(string)<br>          }))<br>        }))<br>        table_constraints = optional(object({<br>          primary_key_columns = optional(list(string))<br>          foreign_keys = optional(object({<br>            referenced_table = object({<br>              project_id = string<br>              dataset_id = string<br>              table_id   = string<br>            })<br>            column_references = object({<br>              referencing_column = string<br>              referenced_column  = string<br>            })<br>            name = optional(string)<br>          }))<br>        }))<br>      })),<br>    }))<br>    bigtable = optional(object({<br>      replicated = optional(bool, false)<br>      tables = map(object({}))<br>    }), null)<br>  })</pre> | n/a | yes |

## Outputs

No outputs.
