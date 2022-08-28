const { DynamoDB } = require("@aws-sdk/client-dynamodb");
const { DynamoDBDocument } = require("@aws-sdk/lib-dynamodb");
const express = require('express')
const cors = require('cors')

// retrieve configuration from environment variables
const {
    NODE_ENV,
    PORT,
    DDB_TABLE_NAME,
    DDB_ENDPOINT,
} = process.env

// create an express server
const app = express()
const port = PORT || 8080
// add a middleware to parse POST body into json
app.use(express.json())
// support CORS requests
app.use(cors())

// create dynamodb document client
let config = {}
if (NODE_ENV == "development" && DDB_ENDPOINT) {
    config = {
        endpoint: DDB_ENDPOINT,
    }
}
const client = new DynamoDB(config);
const ddbDocClient = DynamoDBDocument.from(client);


// readiness check route for Lambda Web Adapter
app.get('/ready', (req, res) => {
    res.send('Yes\n')
})

// GET /votes route - get voting results.
app.get('/votes', async (req, res) => {
    const results = await ddbDocClient.scan({ TableName: DDB_TABLE_NAME })
    const data = results.Items.sort((a, b)=> a.order - b.order)
    res.send(data)
})

// POST /votes route - cast a vote
app.post('/votes', async (req, res) => {
    vote = req.body
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
    res.send(results)
})

// start the express server
app.listen(port, () => {
    console.log(`Voting API listening at http://localhost:${port}`)
})
