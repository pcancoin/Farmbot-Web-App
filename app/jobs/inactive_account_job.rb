# Recurring task that deletes inactive accounts.
class InactiveAccountJob < ApplicationJob
  queue_as :default

  LIMIT = 1000
  INACTIVE_WITH_DEVICE = 11.months.ago
  INACTIVE_NO_DEVICE = 3.months.ago

  WARNING_INTERVALS = { 1 => 30.days, 2 => 7.days, 3 => 1.day }

  def perform
    send_first_warning
    send_warning_number(2)
    send_warning_number(3)
    terminate_accounts
  end

  def send_first_warning
    all_inactive
      .where(inactivity_warning_count: [0, nil])
      .where(inactivity_warning_sent_at: nil)
      .map { |u| u.send_inactivity_warning(1, WARNING_INTERVALS[1]) }
  end

  def send_warning_number(number)
    interval = WARNING_INTERVALS.fetch(number - 1)
    all_inactive
      .where(inactivity_warning_count: number - 1)
      .where("inactivity_warning_sent_at < ?", Time.now + interval)
      .map { |u| u.send_inactivity_warning(number, interval) }
  end

  def terminate_accounts
    puts " === FINISH THIS === "
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
