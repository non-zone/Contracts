import { ValidationResult, NFT } from "../models"

export function validateNFTProps(nft: NFT): ValidationResult {
    if (!nft.name) {
        return { isValid: false, message: 'Property name is a requried field.' }
    }
    if (!nft.description) {
        return { isValid: false, message: 'Property description is a requried field.' }
    }
    if (!nft.image) {
        return { isValid: false, message: 'Property image is a requried field.' }
    }
    return { isValid: true, message: 'The experience is valid.' }
}