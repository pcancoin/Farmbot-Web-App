class InactivityMailer < ApplicationMailer
  attr_reader :user

  SUBJECT = "[%s Notice]" \
            " Your FarmBot Account Will Be Deleted " \
            "Due to Inactivity"
  ORDER = { 1 => "First", 2 => "Second", 3 => "Final" }

  def send_warning(user)
    @user = user
    mail to: user.email, subject: (SUBJECT % warning_ordinality)
  end

  def warning_ordinality
    @warning_ordinality ||= ORDER.fetch(user.inactivity_warning_count || 1)
  end
end
