import { mapStateToProps } from "../map_state_to_props";
import { fakeState } from "../../../__test_support__/fake_state";
import {
  buildResourceIndex
} from "../../../__test_support__/resource_index_builder";
import {
  fakePlant, fakePlantTemplate
} from "../../../__test_support__/fake_state/resources";

describe("mapStateToProps()", () => {
  it("returns findPlant()", () => {
    const state = fakeState();
    const plant = fakePlant();
    plant.body.id = 10;
    state.resources = buildResourceIndex([plant]);
    const uuid = Object.keys(state.resources.index.all)[0];
    const result = mapStateToProps(state);
    expect(result.findPlant(undefined)).toEqual(undefined);
    expect(result.findPlant("10")).toEqual(
      expect.objectContaining({ uuid }));
  });

  it("finds plant template", () => {
    const state = fakeState();
    const template = fakePlantTemplate();
    template.body.id = 10;
    state.resources = buildResourceIndex([template]);
    const uuid = Object.keys(state.resources.index.all)[0];
    state.resources.consumers.farm_designer.openedSavedGarden = "uuid";
    const result = mapStateToProps(state);
    expect(result.findPlant("10")).toEqual(
      expect.objectContaining({ uuid }));
  });
});
