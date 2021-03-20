import express from "express";
import * as bodyParser from "body-parser";
import helmet from "helmet";
import { injectable } from "inversify";
import {
  NFTRouter,
  SwaggerRouter,
} from "./routers";
const cookieParser = require("cookie-parser");
var cors = require('cors');
require('dotenv').config()
const fileUpload = require('express-fileupload');

@injectable()
export class App {
  private _app: express.Application;

  constructor(
    private swaggerRouter: SwaggerRouter,
    private nftRouter: NFTRouter,
  ) {
    this._app = express();
    this.config();
  }

  public get app(): express.Application {
    return this._app;
  }

  private config(): void {

    this._app.use(fileUpload());

    // support application/json
    this._app.use(bodyParser.json());
    // helmet security
    this._app.use(helmet());
    //support application/x-www-form-urlencoded post data
    this._app.use(bodyParser.urlencoded({ extended: false }));

    this._app.use(cookieParser());

    this._app.use(cors());
    //Initialize app routes
    this._initRoutes();

  }

  private _initRoutes() {
    this._app.use("/api/docs", this.swaggerRouter.router);
    this._app.use("/api/nft", this.nftRouter.router);
  }
}