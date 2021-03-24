resource "aws_cognito_user_pool" "" {
  name = "Atlas Users"

  mfa_configuration = "OFF"

  device_configuration {
    challenge_required_on_new_device = false
    device_only_remembered_on_user_prompt = false
  }

  account_recovery_setting {
    recovery_mechanism {
      name     = "verified_email"
      priority = 1
    }

    recovery_mechanism {
      name     = "verified_phone_number"
      priority = 2
    }
  }



}