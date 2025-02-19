import { Component } from "@angular/core";
import { MatDialogRef } from "@angular/material/dialog";
import { ChatService } from "@app/services/chat/chat.service";
import { RoomService } from "@app/services/room/room.service";
import { BehaviorSubject } from "rxjs";
import { environment } from "src/environments/environment";

@Component({
    selector: "app-gif",
    templateUrl: "./gif.component.html",
    styleUrls: ["./gif.component.scss"],
})
export class GifComponent {
    private readonly apiKey: string = environment.tenorAPIKey;
    searchText = "";
    gifs: string[] = [];
    constructor(public dialogRef: MatDialogRef<GifComponent>, private chatService: ChatService, private roomService: RoomService) {
    }

    httpGetAsync(theUrl: string, callback: any)
    {
        // create the request object
        const xmlHttp = new XMLHttpRequest();
        const goodGifs = new BehaviorSubject<any>([]);
        goodGifs.subscribe((gifs) => {
            this.gifs = [];
            for (const gif of gifs)
                this.gifs.push(gif["media_formats"]["nanogif"]["url"]);
        });

        // set the state change callback to capture when the response comes in
        xmlHttp.onreadystatechange = function()
        {
            if (xmlHttp.readyState == 4 && xmlHttp.status == 200)
            {
                const gifs = callback(xmlHttp.responseText);
                goodGifs.next(gifs);
            }
        }

        // open as a GET call, pass in the url and set async = True
        xmlHttp.open("GET", theUrl, true);

        // call send with no params as they were passed in on the url string
        xmlHttp.send(null);

        return;
    }

    // callback for the top 8 GIFs of search
    tenorCallback_search(responsetext: string)
    {
        // Parse the JSON response
        const response_objects = JSON.parse(responsetext);

        return response_objects["results"];

    }

    shared_gifs_id = "16989471141791455574";

    grab_data()
    {
        // set the apikey and limit
        const apikey = this.apiKey;
        const clientkey = "my_test_app";
        const lmt = 8;

        // test search term
        const search_term = "excited";

        // using default locale of en_US
        const search_url = "https://tenor.googleapis.com/v2/search?q=" + this.searchText + "&key=" + apikey +"&client_key=" + clientkey +  "&limit=" + lmt;

        this.httpGetAsync(search_url,this.tenorCallback_search);

        // data will be loaded by each call's callback
        return;
    }

    submit(gif: string): void {
        this.chatService.send(gif, this.roomService.currentRoomChat.value);
        this.close();
    }

    close() {
        this.dialogRef.close();
    }
}