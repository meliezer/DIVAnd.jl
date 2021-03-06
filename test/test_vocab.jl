using Base.Test
import DIVAnd


# Test CF names

collection = DIVAnd.Vocab.CFVocab()
@test haskey(collection,"sea_water_temperature")

entry = collection["sea_water_temperature"]

@test contains(DIVAnd.Vocab.description(entry),"water")
@test DIVAnd.Vocab.canonical_units(entry) == "K"


#collection = DIVAnd.Vocab.Collection("http://www.seadatanet.org/urnurl/collection/P01/current/")

collection = DIVAnd.Vocab.SDNCollection("P01")


url = "http://www.seadatanet.org/urnurl/collection/P01/current/PSALPR01/"
collectionname,tag,key = DIVAnd.Vocab.splitURL(url)

@test collectionname == "P01"
@test tag == "current"
@test key == "PSALPR01"

concept = collection["PSALPR01"]
@test contains(DIVAnd.Vocab.prefLabel(concept),"salinity")
@test contains(DIVAnd.Vocab.notation(concept),"P01")
@test contains(DIVAnd.Vocab.altLabel(concept),"sal")
@test contains(DIVAnd.Vocab.definition(concept),"is")
@test contains(DIVAnd.Vocab.URL(concept),key)

@test typeof(DIVAnd.Vocab.date(concept)) == DateTime


edmo = DIVAnd.Vocab.EDMO()
entry = edmo[1495]
@test typeof(DIVAnd.Vocab.name(entry)) == String
@test typeof(DIVAnd.Vocab.phone(entry)) == String
@test typeof(DIVAnd.Vocab.address(entry))  == String
@test typeof(DIVAnd.Vocab.city(entry)) == String
@test typeof(DIVAnd.Vocab.zipcode(entry)) == String
@test typeof(DIVAnd.Vocab.email(entry)) == String
@test typeof(DIVAnd.Vocab.website(entry)) == String
@test typeof(DIVAnd.Vocab.fax(entry)) == String
@test typeof(DIVAnd.Vocab.country(entry)) == String


collection = DIVAnd.Vocab.SDNCollection("P35")
concept = collection["WATERTEMP"]

units = lowercase(DIVAnd.Vocab.prefLabel(DIVAnd.Vocab.findfirst(concept,"related","P06")))

@test units == "degrees celsius"

label = DIVAnd.Vocab.prefLabel(DIVAnd.Vocab.resolve("SDN:P021:current:TEMP"))
@test label == "Temperature of the water column"

label = DIVAnd.Vocab.prefLabel(DIVAnd.Vocab.resolve("SDN:P021::TEMP"))
@test label == "Temperature of the water column"

edmoname = DIVAnd.Vocab.name(DIVAnd.Vocab.resolve("SDN:EDMO::575"))
@test edmoname == "National Oceanographic Data Committee"

edmoname = DIVAnd.Vocab.name(DIVAnd.Vocab.urn"SDN:EDMO::575")
@test edmoname == "National Oceanographic Data Committee"
