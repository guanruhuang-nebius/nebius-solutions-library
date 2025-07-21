output "o11y_project_id" {
  value = chomp(data.local_file.o11y_project_id.content)
}
