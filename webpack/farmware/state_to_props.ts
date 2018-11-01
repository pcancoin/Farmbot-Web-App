import { Everything } from "../interfaces";
import {
  selectAllImages, maybeGetTimeOffset, maybeGetDevice
} from "../resources/selectors";
import { FarmwareProps, Feature, SaveFarmwareEnv, UserEnv } from "../devices/interfaces";
import { prepopulateEnv } from "./weed_detector/remote_env/selectors";
import * as _ from "lodash";
import {
  getWebAppConfig, selectAllFarmwareEnvs
} from "../resources/selectors_by_kind";
import {
  determineInstalledOsVersion,
  shouldDisplay as shouldDisplayFunc
} from "../util";
import { ResourceIndex } from "../resources/interfaces";
import { TaggedFarmwareEnv } from "farmbot";
import { save, edit, initSave } from "../api/crud";

/** Edit an existing Farmware env variable or add a new one. */
export const saveOrEditFarmwareEnv = (ri: ResourceIndex): SaveFarmwareEnv =>
  (key: string, value: string) => (dispatch: Function) => {
    const fwEnvLookup: Record<string, TaggedFarmwareEnv> = {};
    selectAllFarmwareEnvs(ri)
      .map(x => { fwEnvLookup[x.body.key] = x; });
    if (Object.keys(fwEnvLookup).includes(key)) {
      const fwEnv = fwEnvLookup[key];
      dispatch(edit(fwEnv, { value }));
      dispatch(save(fwEnv.uuid));
    } else {
      dispatch(initSave("FarmwareEnv", { key, value }));
    }
  };

export const reduceFarmwareEnv =
  (ri: ResourceIndex): UserEnv => {
    const farmwareEnv: UserEnv = {};
    selectAllFarmwareEnvs(ri)
      .map(x => { farmwareEnv[x.body.key] = "" + x.body.value; });
    return farmwareEnv;
  };

export function mapStateToProps(props: Everything): FarmwareProps {
  const images = _(selectAllImages(props.resources.index))
    .sortBy(x => x.body.id)
    .reverse()
    .value();
  const firstImage = images[0];
  const currentImage = images
    .filter(i => i.uuid === props.resources.consumers.farmware.currentImage)[0]
    || firstImage;
  const { farmwares } = props.bot.hardware.process_info;
  const conf = getWebAppConfig(props.resources.index);
  const { currentFarmware, firstPartyFarmwareNames } =
    props.resources.consumers.farmware;

  const installedOsVersion = determineInstalledOsVersion(
    props.bot, maybeGetDevice(props.resources.index));
  const shouldDisplay =
    shouldDisplayFunc(installedOsVersion, props.bot.minOsFeatureData);
  const env = shouldDisplay(Feature.api_farmware_env)
    ? reduceFarmwareEnv(props.resources.index)
    : props.bot.hardware.user_env;

  return {
    timeOffset: maybeGetTimeOffset(props.resources.index),
    currentFarmware,
    farmwares,
    botToMqttStatus: "up",
    env: prepopulateEnv(env),
    user_env: env,
    dispatch: props.dispatch,
    currentImage,
    images,
    syncStatus: "synced",
    webAppConfig: conf ? conf.body : {},
    firstPartyFarmwareNames,
    shouldDisplay,
    saveFarmwareEnv: saveOrEditFarmwareEnv(props.resources.index),
  };
}
