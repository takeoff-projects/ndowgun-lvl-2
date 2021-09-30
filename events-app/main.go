package main

import (
	"context"
	"encoding/json"
	"fmt"
	"io/ioutil"
	"log"
	"net/http"
	"os"

	"github.com/google/uuid"
	"github.com/gorilla/mux"

	"cloud.google.com/go/datastore"
)

// Event model
type Event struct {
	UUID     string `json:"id"`
	Title    string `json:"title" datastore:"title"`
	Location string `json:"location" datastore:"location"`
	When     string `json:"when" datastore:"when"`
}

var projectID = os.Getenv("GOOGLE_CLOUD_PROJECT")

func addEventToDB(event Event) (*Event, error) {
	event.UUID = uuid.New().String()

	fmt.Printf("auto-generated id for event %s\n", event.UUID)

	ctx := context.Background()
	projectID := os.Getenv("GOOGLE_CLOUD_PROJECT")
	if projectID == "" {
		log.Fatal(`You need to set the environment variable "GOOGLE_CLOUD_PROJECT"`)
	}
	dsClient, err := datastore.NewClient(ctx, projectID)
	if err != nil {
		log.Fatalf("Could not create datastore client: %v", err)
		return nil, err
	}

	fmt.Printf("Saving an Event, UUID = %s, Title = %s\n", event.UUID, event.Title)
	key := datastore.NameKey("Event", event.UUID, nil)
	_, err = dsClient.Put(ctx, key, &event)
	if err != nil {
		return nil, err
	}

	return &event, nil
}

func home(w http.ResponseWriter, r *http.Request) {
	fmt.Fprintf(w, "Welcome to the Events API!")
	fmt.Println("Endpoint Hit: homeP")
	fmt.Println("saved events from memory -> db")
}

func handleRequests() {
	myRouter := mux.NewRouter().StrictSlash(true)
	myRouter.HandleFunc("/", home)
	myRouter.HandleFunc("/events", getEvents).Methods("GET")
	myRouter.HandleFunc("/events/{id}", getEventbyID).Methods("GET")
	myRouter.HandleFunc("/events", createEvent).Methods("POST")
	myRouter.HandleFunc("/events/{id}", deleteEvent).Methods("DELETE")

	port := os.Getenv("PORT")
	if port == "" {
		port = "8080"
	}

	fmt.Printf("Server running on Port: %s\n", port)
	log.Fatal(http.ListenAndServe(fmt.Sprintf(":%s", port), myRouter))
}

func getEvents(w http.ResponseWriter, r *http.Request) {
	fmt.Println("Endpoint Hit: getEvents")

	if projectID == "" {
		log.Fatal(`You need to set the environment variable "GOOGLE_CLOUD_PROJECT"`)
	}

	var events []Event
	ctx := context.Background()
	client, err := datastore.NewClient(ctx, projectID)
	if err != nil {
		log.Fatalf("Could not create datastore client: %v", err)
	}

	query := datastore.NewQuery("Event").Order("title")
	_, err = client.GetAll(ctx, query, &events)
	if err != nil {
		http.Error(w, err.Error(), 500)
	} else {
		fmt.Printf("Found %d events in db\n", len(events))
	}

	client.Close()

	json.NewEncoder(w).Encode(events)
}

func getEventbyID(w http.ResponseWriter, r *http.Request) {
	fmt.Println("Endpoint Hit: getEventbyID")

	vars := mux.Vars(r)
	id := vars["id"]
	if id == "" {
		http.Error(w, "id must be specified", 400)
	}

	ctx := context.Background()
	client, err := datastore.NewClient(ctx, projectID)
	if err != nil {
		log.Fatalf("Could not create datastore client: %v", err)
	}

	key := datastore.NameKey("Event", id, nil)
	var event Event
	err = client.Get(ctx, key, &event)
	if err != nil || &event == nil {
		http.Error(w, err.Error(), 404)
	}

	client.Close()

	json.NewEncoder(w).Encode(event)
}

func createEvent(w http.ResponseWriter, r *http.Request) {
	fmt.Println("Endpoint Hit: createEvent")

	reqBody, _ := ioutil.ReadAll(r.Body)
	var event Event
	json.Unmarshal(reqBody, &event)

	saved_event, err := addEventToDB(event)
	if err != nil {
		http.Error(w, err.Error(), 500)
	}

	json.NewEncoder(w).Encode(*saved_event)
}

func deleteEvent(w http.ResponseWriter, r *http.Request) {
	fmt.Println("Endpoint Hit: getEventbyID")

	vars := mux.Vars(r)
	id := vars["id"]
	if id == "" {
		http.Error(w, "id must be specified", 400)
	}

	ctx := context.Background()
	client, err := datastore.NewClient(ctx, projectID)
	if err != nil {
		log.Fatalf("Could not create datastore client: %v", err)
	}

	key := datastore.NameKey("Event", id, nil)
	err = client.Delete(ctx, key)
	if err != nil {
		http.Error(w, err.Error(), 404)
	}

	client.Close()
}

func main() {
	handleRequests()
}
