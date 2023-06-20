import { APIGatewayEvent, APIGatewayProxyResultV2, Context } from "aws-lambda";

export const handler = async (event: APIGatewayEvent, context: Context): Promise<APIGatewayProxyResultV2> => {
    console.log(`Event: ${JSON.stringify(event, null, 2)}`)
    console.log(`Context: ${JSON.stringify(context, null, 2)}`)

    return {
        statusCode: 200,
        body: JSON.stringify({
            message: "Hello Hot Reload!"
        })
    }
}