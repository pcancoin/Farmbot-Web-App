require "spec_helper"

describe InactiveAccountJob do
  let!(:user1) do
    FactoryBot.create(:user, name: "user1", last_sign_in_at: 3.years.ago)
  end

  let!(:user2) do
    FactoryBot.create(:user, name: "user2", last_sign_in_at: 3.seconds.ago)
  end

  it "sends the first warning" do
    old_email_count = ActionMailer::Base.deliveries.length
    run_jobs_now { InactiveAccountJob.new.perform }
    user1.reload
    user2.reload
    expect(user1.inactivity_warning_sent_at).not_to eq(nil)
    expect(user1.inactivity_warning_count).not_to eq(nil)
    expect(user2.inactivity_warning_sent_at).to eq(nil)
    expect(user2.inactivity_warning_count).to eq(nil)
    expect(ActionMailer::Base.deliveries.length).to be > old_email_count
    msg = ActionMailer::Base.deliveries.last
    assertion = "You have not logged in to your account in about 3 years"
    expect(msg.body).to include(assertion)
    expect(msg.subject).to include("First Notice")
  end

  it "sends the second warning" do
    user1.update!(inactivity_warning_count: 1, inactivity_warning_sent_at: Time.now + 10.days)
    old_email_count = ActionMailer::Base.deliveries.length
    run_jobs_now { InactiveAccountJob.new.perform }
    user1.reload
    user2.reload
    expect(ActionMailer::Base.deliveries.length).to be > old_email_count
    msg = ActionMailer::Base.deliveries.last
    assertion = "You have not logged in to your account in about 3 years"
    expect(msg.body).to include(assertion)
    expect(user1.reload.inactivity_warning_count).to eq(2)
    expect(msg.subject).to include("Second Notice")
  end

  it "sends the third warning"
  it "deletes after three contact attempts"
end
