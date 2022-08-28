const AWS = require("@aws-sdk/client-iot-data-plane")

const {
    IOT_ENDPOINT,
} = process.env

const iot = new AWS.IoTDataPlane();
const votes_topic = "votes"


module.exports.handler = async (event, context) => {
    console.log(JSON.stringify(event))

    const data = event.Records.map(record => {
        return {
            id: record.dynamodb.Keys.PK.S,
            votes: record.dynamodb.NewImage.votes.N
        }
    })

    const res = await iot.publish({
        topic: votes_topic,
        payload: JSON.stringify(data)
    })

    console.log(JSON.stringify(res))
}