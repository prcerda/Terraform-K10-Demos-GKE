resource "kubernetes_manifest" "bppostgres15" {
  provider   = kubernetes.gke01
  manifest = {
    "actions" = {
      "backupPrehook" = {
        "kind" = ""
        "name" = ""
        "phases" = [
          {
            "args" = {
              "command" = [
                "bash",
                "-o",
                "errexit",
                "-o",
                "pipefail",
                "-c",
                "PGPASSWORD=$${POSTGRES_PASSWORD} psql -U postgres -c \"CHECKPOINT;\"",
              ]
              "container" = "postgresql"
              "namespace" = "{{ .StatefulSet.Namespace }}"
              "pod" = "{{ index .StatefulSet.Pods 0 }}"
            }
            "func" = "KubeExec"
            "name" = "makePGCheckPoint"
          },
        ]
      }
    }
    "apiVersion" = "cr.kanister.io/v1alpha1"
    "kind" = "Blueprint"
    "metadata" = {
      "name" = "postgresql-15-hooks"
      "namespace" = "kasten-io"
    }
  }
}

resource "kubernetes_manifest" "bppostgres17" {
  provider   = kubernetes.gke01
  manifest = {
    "actions" = {
      "backupPrehook" = {
        "kind" = ""
        "name" = ""
        "phases" = [
          {
            "args" = {
              "command" = [
                "bash",
                "-o",
                "errexit",
                "-o",
                "pipefail",
                "-c",
                "PGPASSWORD=$${POSTGRES_POSTGRES_PASSWORD} psql -U postgres -c \"CHECKPOINT;\"",
              ]
              "container" = "postgresql"
              "namespace" = "{{ .StatefulSet.Namespace }}"
              "pod" = "{{ index .StatefulSet.Pods 0 }}"
            }
            "func" = "KubeExec"
            "name" = "makePGCheckPoint"
          },
        ]
      }
    }
    "apiVersion" = "cr.kanister.io/v1alpha1"
    "kind" = "Blueprint"
    "metadata" = {
      "name" = "postgresql-17-hooks"
      "namespace" = "kasten-io"
    }
  }
}


resource "kubernetes_manifest" "bp_pg15_binding" {
  depends_on = [kubernetes_manifest.bppostgres15]
  provider   = kubernetes.gke01
  manifest = {
    "apiVersion" = "config.kio.kasten.io/v1alpha1"
    "kind" = "BlueprintBinding"
    "metadata" = {
      "name" = "postgres15-blueprint-binding"
      "namespace" = "kasten-io"
    }
    "spec" = {
      "blueprintRef" = {
        "name" = "postgresql-15-hooks"
        "namespace" = "kasten-io"
      }
      "resources" = {
        "matchAll" = [
          {
            "type" = {
              "operator" = "In"
              "values" = [
                {
                  "group" = "apps"
                  "resource" = "statefulsets"
                },
              ]
            }
          },
          {
            "annotations" = {
              "key" = "kanister.kasten.io/blueprint"
              "operator" = "DoesNotExist"
            }
          },
          {
            "labels" = {
              "key" = "app.kubernetes.io/instance"
              "operator" = "In"
              "values" = [
                "k10app",
              ]
            }
          },
          {
            "labels" = {
              "key" = "app.kubernetes.io/name"
              "operator" = "In"
              "values" = [
                "postgresql",
              ]
            }
          },
        ]
      }
    }
  }
}


resource "kubernetes_manifest" "bpmongodb" {
  provider   = kubernetes.gke01
  manifest = {
    "actions" = {
      "backupPosthook" = {
        "phases" = [
          {
            "args" = {
              "command" = [
                "bash",
                "-o",
                "errexit",
                "-o",
                "pipefail",
                "-c",
                <<-EOT
                export MONGODB_ROOT_PASSWORD='{{ index .Phases.unlockMongo.Secrets.mongoDbSecret.Data "mongodb-root-password" | toString }}'
                mongosh --authenticationDatabase admin -u root -p "$${MONGODB_ROOT_PASSWORD}" --eval="db.fsyncUnlock()"
                EOT
                ,
              ]
              "container" = "mongodb"
              "namespace" = "{{ .StatefulSet.Namespace }}"
              "pod" = "{{ index .StatefulSet.Pods 0 }}"
            }
            "func" = "KubeExec"
            "name" = "unlockMongo"
            "objects" = {
              "mongoDbSecret" = {
                "kind" = "Secret"
                "name" = "{{ index .Object.metadata.labels \"app.kubernetes.io/instance\" }}"
                "namespace" = "{{ .StatefulSet.Namespace }}"
              } 
            }
          },
        ]
      }
      "backupPrehook" = {
        "phases" = [
          {
            "args" = {
              "command" = [
                "bash",
                "-o",
                "errexit",
                "-o",
                "pipefail",
                "-c",
                <<-EOT
                export MONGODB_ROOT_PASSWORD='{{ index .Phases.lockMongo.Secrets.mongoDbSecret.Data "mongodb-root-password" | toString }}'
                mongosh --authenticationDatabase admin -u root -p "$${MONGODB_ROOT_PASSWORD}" --eval="db.fsyncLock()"
                
                EOT
                ,
              ]
              "container" = "mongodb"
              "namespace" = "{{ .StatefulSet.Namespace }}"
              "pod" = "{{ index .StatefulSet.Pods 0 }}"
            }
            "func" = "KubeExec"
            "name" = "lockMongo"
            "objects" = {
              "mongoDbSecret" = {
                "kind" = "Secret"
                "name" = "{{ index .Object.metadata.labels \"app.kubernetes.io/instance\" }}"
                "namespace" = "{{ .StatefulSet.Namespace }}"
              }
            }
          },
        ]
      }
    }
    "apiVersion" = "cr.kanister.io/v1alpha1"
    "kind" = "Blueprint"
    "metadata" = {
      "name" = "mongo-hooks"
      "namespace" = "kasten-io"
    }
  }
}

resource "kubernetes_manifest" "bp_mongo_binding" {
  provider   = kubernetes.gke01
  depends_on = [kubernetes_manifest.bpmongodb]
  manifest = {
    apiVersion = "config.kio.kasten.io/v1alpha1"
    kind       = "BlueprintBinding"

    metadata = {
      name = "mongodb-blueprint-binding"
      namespace = "kasten-io"
    }

    spec = {
        blueprintRef = {
            name = "mongo-hooks"
            namespace = "kasten-io"
        }
        resources = {
            matchAll = [
                {
                    type = {
                        operator = "In"
                        values = [
                            {
                                group = "apps"
                                resource = "StatefulSets"
                            }
                        ]
                    }
                },
                {
                    annotations = {
                        key = "kanister.kasten.io/blueprint"
                        operator = "DoesNotExist"
                    }
                },
                {
                    "labels"= {
                        key= "app.kubernetes.io/name"
                        operator= "In"
                        values= ["mongo"]
                    }
                }
            ]
        }
    }
  }
}
