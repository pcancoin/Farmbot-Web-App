import { uniq } from "lodash";
import {
    selectAllSensors,
    selectAllSensorReadings
} from "../resources/selectors";
import { Everything } from "../interfaces";
import { Props } from "./interfaces";

export function mapStateToProps(props: Everything): Props {
    return {
        sensors: uniq(selectAllSensors(props.resources.index)),
        sensorReadings: selectAllSensorReadings(props.resources.index)
    };
}
