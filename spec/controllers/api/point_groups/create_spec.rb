require "spec_helper"

describe Api::PointGroupsController do
  include Devise::Test::ControllerHelpers
  let(:user) { FactoryBot.create(:user) }
  let(:device) { user.device }
  let(:point_ids) do
    [
      :tool_slot,
      :generic_pointer,
      :plant,
    ].map { |x| FactoryBot.create(x, device: device).id }.sort
  end

  it "creates a point group" do
    sign_in user
    payload = { name: "this is a group", point_ids: point_ids }
    before = PointGroup.count
    post :create, body: payload.to_json, format: :json
    expect(response.status).to eq(200)
    expect(before).to be < PointGroup.count

    expect(json[:name]).to eq(payload[:name])
    expect(json[:point_ids].count).to eq(3)
    point_ids.map do |this_id|
      expect(json[:point_ids]).to include(this_id)
    end
    expect(json[:sort_type]).to eq("xy_ascending")
  end

  it "alerts the user about bad point_ids" do
    sign_in user
    point_ids = [0]
    payload = { name: "this is a group", point_ids: point_ids }
    before = PointGroup.count
    post :create, body: payload.to_json, format: :json
    expect(response.status).to eq(422)
    expect(before).to eq(PointGroup.count)
    expect(json.fetch(:points)).to include(PointGroups::Create::BAD_POINT_IDS)
  end

  it "disallows malformed sort_types" do
    sign_in user
    payload = { name: "_", point_ids: [], sort_type: "q" }
    before = PointGroup.count
    post :create, body: payload.to_json, format: :json
    expect(response.status).to eq(422)
    expect(json[:sort_type]).to include(PointGroup::BAD_SORT.split("}").last)
  end
end
