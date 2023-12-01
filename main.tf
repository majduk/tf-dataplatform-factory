# Copyright 2023 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

module "gcs-df-tmp" {
  source         = "../../../cloud-foundation-fabric/modules/gcs"
  count  	 = try(var.service_config.dataflow == null) ? 0 : 1
  project_id     = var.project_id
  name	         = replace("${var.prefix}_bl_df_tmp_0","_","-")
  location       = var.region
  storage_class  = "REGIONAL"
  #encryption_key = var.cmek_encryption ? module.kms[0].keys.key-gcs.id : null
  #force_destroy  = !var.deletion_protection
}

resource "google_dataflow_job" "big_lake_job" {
  count             = try(var.service_config.dataflow == null) ? 0 : 1
  project           = var.project_id
  name	            = replace("${var.prefix}_bl_df_0","_","-")
  on_delete         = "cancel"
  region            = var.region
  template_gcs_path = try(var.service_config.dataflow.template_path, "")
  temp_gcs_location = try(module.gcs-df-tmp[0].url,null)
  service_account_email = try(var.service_config.dataflow.worker_sa, null)
  network           = try(var.service_config.dataflow.network, null)
  subnetwork        = try(var.service_config.dataflow.subnetwork, null)
  ip_configuration  = "WORKER_IP_PRIVATE"
  machine_type      = try(var.service_config.dataflow.machine_type, null)
  parameters 	    = try(var.service_config.dataflow.parameters, null)
}

module "big_lake_dataset" {
  source         = "../../../cloud-foundation-fabric/modules/bigquery-dataset"
  count    	 = try(var.service_config.bigquery == null) ? 0 : 1
  project_id     = var.project_id
  id		 = replace("${var.prefix}_bl_bq_0","-","_")
  location       = var.region
  #encryption_key = try(local.service_encryption_keys.bq, null)
  tables 	 = var.service_config.bigquery.tables
}

module "bigtable-instance" {
  source         = "../../../cloud-foundation-fabric/modules/bigtable-instance"
  count    	 = try(var.service_config.bigtable == null) ? 0 : 1
  project_id     = var.project_id
  name	         = replace("${var.prefix}_bl_bt_0","_","-")
  #deletion_protection  = !var.deletion_protection
  #TODO: if replication
  clusters 	 = {
    primary = {
      zone = "${var.region}-a"
      autoscaling = {
        min_nodes  = 3
        max_nodes  = 7
        cpu_target = 70
      }
    }
  }
  tables 	 = try(var.service_config.bigtable.tables, null)
}
