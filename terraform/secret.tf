resource "google_secret_manager_secret" "bakatare_discord_bot_token" {
  secret_id = "bakatare-discord-bot-token"

  replication {
    auto {}
  }
}

resource "google_secret_manager_secret_iam_member" "bakatare_discord_bot_token_accessor" {
  secret_id = google_secret_manager_secret.bakatare_discord_bot_token.id
  role      = "roles/secretmanager.secretAccessor"
  member    = google_service_account.bakatare.member
}
