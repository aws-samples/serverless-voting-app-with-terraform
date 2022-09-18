const { DynamoDB } = require("@aws-sdk/client-dynamodb");
const { DynamoDBDocument } = require("@aws-sdk/lib-dynamodb");

// retrieve configuration from environment variables
const {
    DDB_TABLE_NAME,
} = process.env

// create dynamodb document client
const client = new DynamoDB();
const ddbDocClient = DynamoDBDocument.from(client);

module.exports.handler = async (event, context) => {
    const vote_counts = {
        dog: 0,
        cat: 0,
        bird: 0
    }

    event.Records.forEach(msg => {
        const vote = JSON.parse(msg.body)
        vote_counts[vote.id] = vote_counts[vote.id] + 1
    })

    console.log(JSON.stringify(vote_counts))

    for (const [key, value] of Object.entries(vote_counts)) {
        await ddbDocClient.update({
            TableName: DDB_TABLE_NAME,
            Key: {
                PK: key,
                SK: "total",
            },
            UpdateExpression: `SET votes = if_not_exists(votes, :default_votes) + :value`,
            ExpressionAttributeValues: {
                ":default_votes": 0,
                ":value": value,
            },
        })
    }
}
