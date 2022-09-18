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
    console.log(JSON.stringify(event))

    const vote = JSON.parse(event.body)
    const results = await ddbDocClient.update({
        TableName: DDB_TABLE_NAME,
        Key: {
            PK: vote.id,
            SK: "total",
        },
        UpdateExpression: `SET votes = if_not_exists(votes, :default_votes) + :value`,
        ExpressionAttributeValues: {
            ":default_votes": 0,
            ":value": 1,
        },
    })
    return JSON.stringify(results)
}
