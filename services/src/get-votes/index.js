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
    // read votes results from DynamoDB
    const results = await ddbDocClient.scan({ TableName: DDB_TABLE_NAME })
    return {
        statusCode: 200,
        body: JSON.stringify(results.Items)
    }
}
