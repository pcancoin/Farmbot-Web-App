# Recurring task that deletes inactive accounts.
class InactiveAccountJob < ApplicationJob
  queue_as :default

  INACTIVE_WITH_DEVICE = 11.months.ago
  INACTIVE_NO_DEVICE = 3.months.ago

  WARNING_INTERVALS = {
    1 => 30.days,
    2 => 7.days,
    3 => 1.day,
  }

  def perform(limit = 1000)
    send_first_warning
    send_second_warning
    send_third_warning
  end

  private

  def all_inactive
    return @all_inactive if @all_inactive

    # They signed up for an account, but never configured a device.
    nay_device = User
      .includes(:device)
      .where("devices.fbos_version" => nil)
      .references(:devices)

    # They signed up for an account and once had a working device.
    yay_device = User
      .includes(:device)
      .where.not("devices.fbos_version" => nil)
      .references(:devices)

    inactive_3mo = nay_device.where("last_sign_in_at < ?")
    inactive_11mo = yay_device.where("last_sign_in_at < ?", INACTIVE_WITH_DEVICE)

    @all_inactive =
      inactive_11mo.or(inactive_3mo).order(updated_at: :desc).limit(limit)
  end
end
