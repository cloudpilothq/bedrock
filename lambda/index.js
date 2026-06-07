exports.handler = async (event) => {
    for (const record of event.Records) {
        const filename = record.s3.object.key;
        console.log(`Image received: ${filename}`);
    }
    return { statusCode: 200, body: 'Success' };
};
