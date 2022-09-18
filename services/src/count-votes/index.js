

module.exports.handler = async (event, context) => {
    console.log(JSON.stringify(event))

    // const vote = JSON.parse(event.body)
    // const results = await ddbDocClient.update({
    //     TableName: DDB_TABLE_NAME,
    //     Key: {
    //         PK: vote.id,
    //         SK: "total",
    //     },
    //     UpdateExpression: `SET votes = if_not_exists(votes, :default_votes) + :value`,
    //     ExpressionAttributeValues: {
    //         ":default_votes": 0,
    //         ":value": 1,
    //     },
    // })
    // return JSON.stringify(results)

}
