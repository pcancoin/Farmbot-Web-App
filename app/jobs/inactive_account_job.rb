# Recurring task that deletes inactive accounts.
class InactiveAccountJob < ApplicationJob
  queue_as :default

  LIMIT = 1000
  INACTIVE_WITH_DEVICE = 11.months.ago
  INACTIVE_NO_DEVICE = 3.months.ago

  WARNING_INTERVALS = { 1 => 30.days, 2 => 7.days, 3 => 1.day }

  def perform
    send_first_warning
  end

  def send_first_warning
    all_inactive
      .where(inactivity_warning_count: [0, nil])
      .where(inactivity_warning_sent_at: nil)
      .map { |u| u.send_inactivity_warning(1, WARNING_INTERVALS[1]) }
  end

  private

  # Returns a Map. Key is the number of warnings sent, value is a User object
  # (not a device, but device is preloaded)
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

    inactive_3mo = nay_device.where("last_sign_in_at < ?", INACTIVE_NO_DEVICE)
    inactive_11mo = yay_device.where("last_sign_in_at < ?", INACTIVE_WITH_DEVICE)
    @all_inactive = inactive_11mo
      .or(inactive_3mo)
      .order("RANDOM()")
      .limit(LIMIT)
  end
end
