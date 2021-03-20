import { injectable } from "inversify";
import { Router } from "express";
import { NFTController } from "../controllers";

@injectable()
export class NFTRouter {
  private readonly _router: Router;

  constructor(private nftController: NFTController) {
    this._router = Router({ strict: true });
    this.init();
  }

  private init(): void {
    this._router.post("/", this.nftController.post);
    this._router.post("/image", this.nftController.postImage);
    this._router.get("/thegraph", this.nftController.fetchNFTData);
  }

  public get router(): Router {
    return this._router;
  }
}
