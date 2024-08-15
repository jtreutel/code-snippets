package main

import (
	"context"
	"encoding/csv"
	"flag"
	"fmt"
	"hash/crc32"
	"log"
	"os"

	secretmanager "cloud.google.com/go/secretmanager/apiv1"
	"cloud.google.com/go/secretmanager/apiv1/secretmanagerpb"
)

func readCsvFile(filePath string) ([][]string, error) {
	f, err := os.Open(filePath)
	if err != nil {
		log.Fatal("Unable to read input file "+filePath+": ", err)
	}
	defer f.Close()

	csvReader := csv.NewReader(f)
	records, err := csvReader.ReadAll()
	if err != nil {
		log.Fatal("Unable to parse file as CSV for "+filePath+": ", err)
	}

	return records, err
}

func createGcpSecrets(records [][]string, gcpProject string) {

	ctx := context.Background()
	c, err := secretmanager.NewClient(ctx)
	if err != nil {
		log.Fatal("Could not create Secret Manager client: ", err)
	}
	defer c.Close()

	//Loops through records to create named secret and a secret version containing the payload
	for i := 0; i < len(records); i++ {

		secretId := records[i][0]

		// Build the create secret request
		req := &secretmanagerpb.CreateSecretRequest{
			Parent:   gcpProject,
			SecretId: secretId,
			Secret: &secretmanagerpb.Secret{
				Replication: &secretmanagerpb.Replication{
					Replication: &secretmanagerpb.Replication_Automatic_{
						Automatic: &secretmanagerpb.Replication_Automatic{},
					},
				},
			},
		}

		// Call the API to create the Secret
		result, err := c.CreateSecret(ctx, req)
		if err != nil {
			log.Printf("Failed to create secret for %s: %v", secretId, err)
			continue // Skip this record but don't stop the entire execution
		}
		fmt.Fprintf(os.Stdout, "Created secret: %s\n", result.Name)
	}
}

func loadGcpSecrets(records [][]string, gcpProject string) {

	ctx := context.Background()
	c, err := secretmanager.NewClient(ctx)
	if err != nil {
		log.Fatal("Could not create Secret Manager client: ", err)
	}
	defer c.Close()

	for i := 0; i < len(records); i++ {
		secretPayload := records[i][1]

		parent := gcpProject + "/secrets/" + records[i][0]

		// Compute checksum
		crc32c := crc32.MakeTable(crc32.Castagnoli)
		checksum := int64(crc32.Checksum([]byte(secretPayload), crc32c))

		// Build the request.
		req := &secretmanagerpb.AddSecretVersionRequest{
			Parent: parent,
			Payload: &secretmanagerpb.SecretPayload{
				Data:       []byte(secretPayload),
				DataCrc32C: &checksum,
			},
		}

		//Call API
		result, err := c.AddSecretVersion(ctx, req)
		if err != nil {
			log.Printf("Failed to add secret version for %s: %v", parent, err)
			continue // Skip this record but don't stop the entire execution
		}
		fmt.Fprintf(os.Stdout, "Added secret version: %s\n", result.Name)

	}

}

func main() {

	pathPtr := flag.String("path", "./secrets.csv", "path to secrets file")
	projectNamePtr := flag.String("project", "", "name of gcp project")
	createSecretsPtr := flag.Bool("create", false, "whether to create secrets")

	flag.Parse()

	// Check if the project name is provided
	if *projectNamePtr == "" {
		log.Fatal("Error: Project name must be specified")
	}

	// Read CSV file and check for errors
	records, err := readCsvFile(*pathPtr)
	if err != nil {
		log.Fatalf("Error reading CSV file: %v", err)
	}

	fmt.Println(records)

	fmt.Println(*projectNamePtr)

	//TODO: Add GCP auth

	if *createSecretsPtr {
		createGcpSecrets(records, *projectNamePtr)
	}

	loadGcpSecrets(records, *projectNamePtr)
}
