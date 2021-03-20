import { Buckets, KeyInfo } from '@textile/hub'
require('dotenv').config()
import * as fs from 'fs';

const keyInfo: KeyInfo = {
  key: process.env.TEXTILE_KEY,
  secret: process.env.TEXTILE_SECRET
}

const bucketName = process.env.BUCKET_NAME

export async function pushJSON(json: any): Promise<string> {
  const buckets = await Buckets.withKeyInfo(keyInfo)
  const { root } = await buckets.getOrCreate(bucketName)
  if (!root) throw new Error('bucket not created')
  const buf = Buffer.from(JSON.stringify(json))
  const links = await buckets.pushPath(root.key, 'nft.json', buf, { root })
  return `https://hub.textile.io${links.path.path}`;
}

export async function pushImage(file: Buffer, extension: string): Promise<string> {
  const buckets = await Buckets.withKeyInfo(keyInfo)
  const { root } = await buckets.getOrCreate(bucketName)
  if (!root) throw new Error('bucket not created')
  const links = await buckets.pushPath(root.key, `image.${extension}`, file, { root })
  return `https://hub.textile.io${links.path.path}`;
}