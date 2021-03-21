import { Response } from "express";
import { injectable } from "inversify";
import { validateNFTProps } from "../services/nft.service";
import { NFT } from "../models";
import {
    LoggerService,
} from "../services";
import { pushImage, pushJSON } from '../textile.config';
const axios = require('axios')


@injectable()
export class NFTController {

    constructor(
        private loggerService: LoggerService,
    ) {
    }

    public postImage = async (req: any, res: Response) => {
        if (!req.files || Object.keys(req.files).length === 0) {
            return res.status(400).send('No files were uploaded.');
        }

        const image = req.files.image;
        const uploadPath = __dirname + '/images/' + image.name;

        console.log(uploadPath);
        console.log(req.files.image); // the uploaded file object
        const extension = image.name.substr(image.name.lastIndexOf('.') + 1);
        console.log(extension)
        const link = await pushImage(req.files.image.data, extension);
        res.status(200).send({ link });
    }

    public post = async (req: any, res: Response) => {
        try {
            const nft = req.body as NFT;
            const validationResult = validateNFTProps(nft);
            if (validationResult.isValid) {
                const url = await pushJSON({
                    name: nft.name,
                    description: nft.description,
                    image: nft.image,
                    isMemory: nft.isMemory,
                    lat: nft.lat,
                    long: nft.long
                });
                res.status(201).send({ url });
            } else {
                res.status(400).send(validationResult);
            }
        } catch (err) {
            this.loggerService.error(err);
            res.status(500).send({ error: "Something went wrong, please try again later." });
        }
    }

    public fetchNFTData = async (req: any, res: Response) => {
        try {

            const subgraphRes = await axios.post('https://api.thegraph.com/subgraphs/name/maticnetwork/mainnet-root-subgraphs', {
                query: `
                {
                    stakingNFTTransfers(first:100) {
                      id
                      tokenId
                      currentOwner
                      previousOwners
                    }
                  }                  
                `
            });
            return res.status(200).send(subgraphRes.data.data.stakingNFTTransfers);

        } catch (err) {
            this.loggerService.error(err);
            res.status(500).send({ error: "Something went wrong, please try again later." });
        }
    }
}