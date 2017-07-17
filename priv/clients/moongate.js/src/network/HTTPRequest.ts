export class HTTPRequest {
  static fetch(url: string, type: string, callback: Function): XMLHttpRequest {
    var req = new XMLHttpRequest();

    req.onreadystatechange = function() {
      if (this.readyState === 4 && this.status === 200) {
        switch(type) {
          case "json":
            return callback(JSON.parse(this.response));
          default:
            return callback(this.response);
        }
      }
    };
    req.open("GET", url, true);
    req.send();

    return req;
  }
}
