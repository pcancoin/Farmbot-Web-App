import { uniq } from "lodash";
//import { Everything } from "../interfaces";
import {
    selectAllSensors,
    selectAllSensorReadings
} from "../resources/selectors";

export function mapStateToProps(props: Everything): Props {
    return {
        sensors: uniq(selectAllSensors(props.resources.index)),
        sensorReadings: selectAllSensorReadings(props.resources.index)
    };
}
