# Red Hat Catalog Enablement for the IBM Operator Catalog

IBM provides a catalog of product offerings in the form of a `catalog index image`.  The catalog image can be enabled on a Red Hat OpenShift 4.4 or later cluster via a `CatalogSource` resource, in order to show IBM offerings in the Red Hat OpenShift operator catalog.  

### Command Line Enablement

The catalog can be enabled by applying the following YAML file to the OpenShift cluster:

```yaml
apiVersion: operators.coreos.com/v1alpha1
kind: CatalogSource
metadata:
  name: ibm-operator-catalog
  namespace: openshift-marketplace
spec:
  displayName: IBM Operator Catalog
  publisher: IBM
  sourceType: grpc
  image: docker.io/ibmcom/ibm-operator-catalog
  updateStrategy:
    registryPoll:
      interval: 45m
```

Command Line: `$ oc apply -f catalog_source.yaml -n openshift-marketplace`

### Verify the Command Line Install

```
$ oc get CatalogSources ibm-operator-catalog -n openshift-marketplace
```

This will give you the following on error:
```
Error from server (NotFound): catalogsources.operators.coreos.com "ibm-operator-catalog" not found
```

This will give you the following on success: 
```
NAME                   DISPLAY                 TYPE   PUBLISHER      AGE
ibm-operator-catalog   ibm-operator-catalog    grpc   IBM Content    9d
```

### Additional Support

For additional support related to Cloud Paks and Container Software please reference [the general support documentation](https://www.ibm.com/support/knowledgecenter/en/cloudpaks).