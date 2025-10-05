package main

import (
    "log"
    "net/http"
    "encoding/json"
    "bytes"
    "time"
    "io/ioutil"
    "net"
    "os"
)

type Settings struct {
    Port     string `json:"port"`
    Override bool   `json:"override"`
}

func main() {
    port := readSettings().Port
    log.Println("teenyHTTP starting...")

    http.HandleFunc("/", webHandler)
    
    ipAddressArray, err := net.InterfaceAddrs()
    if err != nil {
        log.Fatal("err detecting ip address:  ", err)
    }

    for _, ipAddress := range ipAddressArray {
        if ipNet, ok := ipAddress.(*net.IPNet); ok && !ipNet.IP.IsLoopback() {
            if ipNet.IP.To4() != nil {
                log.Printf("listening on http://%s:%s\n", ipNet.IP, port)
            }
        }
    }

    log.Fatal(http.ListenAndServe(":"+port, nil))
}

func readSettings() Settings {
    var settings Settings
    fileBytes, err := os.ReadFile("settings.json")
    if err != nil {
        log.Fatalf("error reading settings file:  ", err)
    }

    err = json.Unmarshal(fileBytes, &settings)
    if err != nil {
        log.Fatalf("err reading settings.json", err)
    }
    return settings
}

func webHandler(w http.ResponseWriter, r *http.Request) {
    var requestedPage string
    if readSettings().Override {
        requestedPage = readOverrideJSON(r.URL.Path[1:])
        if requestedPage == "404" {
            http.NotFound(w, r)
            log.Printf("   recieved request for restricted file")
            return
        }
    } else {
        requestedPage = r.URL.Path[1:]
    }
    log.Printf("requested page == %s", requestedPage)

    webPageContent, err := ioutil.ReadFile(requestedPage)
    if err != nil {
        log.Println("err reading file for requested webpage:  ", err)
        http.NotFound(w, r)
        return
    }
     
    webpageReader := bytes.NewReader(webPageContent)

    http.ServeContent(w, r, requestedPage, time.Now(), webpageReader)
}

func readOverrideJSON(query string) string {
    overrideJSONbyte, err := ioutil.ReadFile("override.json")
    if err != nil {
        log.Fatalf("err reading override.json")
    }

    var rawData map[string]interface{}
    err = json.Unmarshal(overrideJSONbyte, &rawData)
    if err != nil {
        log.Fatalf("err unmarshaling override.json:  %v", err)
    }

    file, ok := rawData[query].(string)
    if !ok {
        return query
    } else {
        log.Printf("...overriding")
    }
    return file
}