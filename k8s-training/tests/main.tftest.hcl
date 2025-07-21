###GLOBALVARIABLES OWERWITE BLOCK###
variables {
  gpu_nodes_platform = "gpu-h100-sxm"
  enable_loki        = false # TODO: Disabling Loki since not possible to delete non-empty storage bucket
}
######
run "k8s_training_apply" {
  command = apply
  plan_options {
    target = [
      nebius_mk8s_v1_cluster.k8s-cluster
    ]
  }
}

run "k8s_node_groups_training_apply" {
  command = apply
  plan_options {
    target = [
      nebius_mk8s_v1_node_group.cpu-only,
      nebius_mk8s_v1_node_group.gpu
    ]
  }
}

run "full_training_apply" {
  command = apply
}

run "test_mode_k8s_training_apply" {
  command = apply

  variables {
    test_mode = true
  }

  assert {
    condition     = module.nccl-test[0].helm_release_status == "deployed"
    error_message = "Fail to deploy helm nccl-test release ${module.nccl-test[0].helm_release_status}"
  }
}
