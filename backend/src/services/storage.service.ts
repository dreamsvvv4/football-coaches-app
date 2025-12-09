import { S3 } from 'aws-sdk';
import { v4 as uuidv4 } from 'uuid';
import { promisify } from 'util';
import fs from 'fs';
import path from 'path';

const s3 = new S3();
const readFile = promisify(fs.readFile);
const writeFile = promisify(fs.writeFile);

class StorageService {
    private bucketName: string;

    constructor() {
        this.bucketName = process.env.AWS_S3_BUCKET_NAME || '';
    }

    async uploadFile(filePath: string): Promise<string> {
        const fileContent = await readFile(filePath);
        const fileName = `${uuidv4()}-${path.basename(filePath)}`;

        const params = {
            Bucket: this.bucketName,
            Key: fileName,
            Body: fileContent,
        };

        await s3.upload(params).promise();
        return fileName;
    }

    async deleteFile(fileName: string): Promise<void> {
        const params = {
            Bucket: this.bucketName,
            Key: fileName,
        };

        await s3.deleteObject(params).promise();
    }

    async getFileUrl(fileName: string): Promise<string> {
        const params = {
            Bucket: this.bucketName,
            Key: fileName,
            Expires: 60 * 60, // URL valid for 1 hour
        };

        return s3.getSignedUrl('getObject', params);
    }
}

export default new StorageService();