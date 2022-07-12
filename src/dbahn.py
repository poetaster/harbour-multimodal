# -*- coding: utf-8 -*-
import pyotherside
from datetime import datetime, timedelta
from dbahn_client.dbahn_client import DbahnClient
import multimodal_structures
import multimodal_functions

class Dbahn:
  MAX_RESULTS = 200
  TIME_WINDOW = 60

  def __init__(self):
    print('db init')

    self.owner_to_pc = {
      "01":"DB3",
      "04":"DB3",
      "05":"DB3",
      "06":"DB3",
      "07":"DB3",
      "0S":"S3",
      "20JI":"DPN",
      "20MJ":"DPN",
      "20":"RZD",
      "3230":"VBG1",
      "518O":"PKP",
      "51":"PKP",
      "54":"CD1",
      "55":"MAV",
      "56":"ZSS",
      "78":"HZ",
      "79":"SZ",
      "800151":"DB5",
      "800152":"DB5",
      "800153":"DB5",
      "800154":"DB5",
      "800155":"DB5",
      "800156":"DB5",
      "800157":"DB5",
      "800158":"DB5",
      "800159":"DB5",
      "800160":"DB5",
      "800161":"DB5",
      "800163":"DB5",
      "800164":"DB5",
      "800201":"DB6",
      "800244":"DB6",
      "800271":"DB6",
      "800279":"DB6",
      "800295":"DB6",
      "8002A3":"DB6",
      "8002B5":"DB6",
      "800301":"DB7",
      "800304":"DB7",
      "800305":"DB7",
      "800306":"DB7",
      "800310":"DB7",
      "800311":"DB7",
      "800318":"DB7",
      "800333":"DB7",
      "800337":"DB7",
      "800338":"DB7",
      "800348":"DB7",
      "800349":"DB7",
      "800351":"DB7",
      "800352":"DB7",
      "800354":"DB7",
      "800363":"DB7",
      "8003A5":"DB7",
      "8003A":"DB7",
      "8003G1":"DB7",
      "8003G2":"DB7",
      "8003H5":"DB7",
      "8003S":"DB7",
      "800413":"DB8",
      "800416":"DB8",
      "800417":"DB8",
      "800430":"EGB",
      "800445":"DB8",
      "800456":"DB8",
      "800462":"DB8",
      "800469":"DB8",
      "800478":"DB8",
      "800486":"DB8",
      "800487":"DB8",
      "800489":"DB8",
      "8004A9":"DB8",
      "8004NT":"DB8",
      "8004OB":"OBS1",
      "800515":"DB9",
      "800523":"KHB",
      "800528":"DBRSBRM",
      "800535":"DB9",
      "800536":"DB9",
      "800553":"DB9",
      "800574":"DB9",
      "8005A4":"DB9",
      "8005KG":"DB9",
      "8005MW":"DB9",
      "8005ND":"DB9",
      "800603":"WFB",
      "800618":"WFB",
      "800619":"DB10",
      "800622":"RAB3",
      "800631":"DB10",
      "800632":"RAB3",
      "800640":"SWX",
      "800643":"DB10",
      "800647":"DB10",
      "800693":"RAB3",
      "800694":"RAB3",
      "8006A7":"WFB",
      "8006B7":"DB10",
      "8006B8":"DB10",
      "8006B9":"DB10",
      "8006C1":"DB10",
      "8006C2":"DB10",
      "8006C4":"DB10",
      "8006C5":"DB10",
      "8006C6":"DB10",
      "8006C7":"RAB3",
      "8006C8":"RAB3",
      "8006C9":"RAB3",
      "8006D1":"RAB3",
      "8006D3":"WFB",
      "8006D6":"DB10",
      "8006D8":"DB10",
      "8006E3":"RAB3",
      "8006RA":"RAB3",
      "8006SH":"DB10",
      "800714":"DB11",
      "800720":"DB11",
      "800721":"DB11",
      "800725":"DB11",
      "800733":"DB11",
      "800734":"DB11",
      "800742":"DB11",
      "800746":"DB11",
      "800755":"DB11",
      "800759":"DB11",
      "800765":"DB11",
      "800767":"DB11",
      "800768":"DB11",
      "800772":"DB11",
      "800785":"DB11",
      "800790":"DB11",
      "8007D4":"DB11",
      "8007D5":"DB11",
      "8007DU":"DB11",
      "8007H1":"DB11",
      "801382":"GBB1",
      "8013D":"SOB",
      "8013E":"SOB",
      "801512":"DB12",
      "801513":"DB12",
      "801518":"DB12",
      "801526":"DB12",
      "801539":"DB12",
      "801566":"DB12",
      "801591":"DB12",
      "801599":"DBRM",
      "8015A1":"DB12",
      "8015A6":"DB12",
      "8015FR":"DB12",
      "8015RP":"DB12",
      "8015RR":"DB12",
      "80Bus":"Bus1",
      "80":"D4",
      "80E204":"DB6",
      "80S603":"WFB",
      "80S618":"WFB",
      "80S631":"DB10",
      "80SSP":"D",
      "80TRI":"EC",
      "810030":"ÖPO",
      "81":"ÖBB",
      "83":"TI1",
      "84":"NS",
      "850065":"THU1",
      "850193":"URh",
      "850195":"SBS1",
      "857000":"SBB",
      "857221":"UNB",
      "85DBSH":"SBB",
      "85":"SBB",
      "860087":"ARR3",
      "861002":"DSB1",
      "86":"DSB1",
      "87":"SCF",
      "88":"SCB",
      "A0":"AKN",
      "A5":"VEN",
      "A8":"ALX",
      "A8N":"ALX",
      "A8S":"ALX",
      "A9":"ag",
      "AB":"AB",
      "ABCDEF":"DPN",
      "ABIRE":"ABBW",
      "ABRB":"ABBW",
      "ABRE":"ABBW",
      "ABRM":"ABRM",
      "AMHBX":"ABRM",
      "AMRB":"RB2",
      "AMRE":"RE",
      "AMSE":"SE1",
      "AR":"ABR1",
      "ARRB":"AR",
      "ARRE":"AR",
      "ARS":"AR",
      "AV":"DB3",
      "AX":"AX",
      "B1":"DPN",
      "B2":"DPN",
      "B3":"P2",
      "B4":"DPN",
      "B5":"UNB",
      "B6":"DPN",
      "B7":"DPN",
      "B9":"DPN",
      "BB":"DPN",
      "BD":"SDG",
      "BE":"BE",
      "BW":"DPN",
      "C6":"KTB",
      "C8":"LEO",
      "CW":"ODEG",
      "CX":"RB4",
      "CXRB":"RB4",
      "CXRE":"RB4",
      "D2":"P3",
      "D3IG":"RTB",
      "D3":"RTB1",
      "E0":"EVB1",
      "E3":"P4",
      "EB":"EB1",
      "ED":"FEG",
      "EX":"EBx",
      "F1":"DPN",
      "F7":"BOB2",
      "FLX10":"FLX",
      "FLX30":"FLX",
      "GA":"GOAH",
      "GAIRE":"GOAH",
      "GAMEX":"GAMEX",
      "GARB":"GOAH",
      "GARE":"GOAH",
      "H4":"H4",
      "H6":"HzL",
      "H7":"HzL",
      "HK":"HKX",
      "HX":"HEX1",
      "I9":"P7",
      "K4":"HLB",
      "K4RB":"HLB",
      "K4RE":"HLB",
      "K6":"KVV",
      "KD":"KD3",
      "kvg001":"SPNV",
      "kvvSTR":"KVG",
      "L7":"SBB1",
      "L8":"BLB",
      "LC":"LOC",
      "LD":"TL4",
      "LDTL":"TL3",
      "LDTLX":"TLX",
      "M1":"P10",
      "M2":"S4",
      "M8":"M",
      "M9":"MSB",
      "MD":"RB6",
      "MDRB":"RB6",
      "MDRE":"RB6",
      "MUDHEF":"DELHA",
      "MW":"MBB1",
      "N0":"neg",
      "N1":"NWB",
      "N2":"NWB",
      "N4":"RB7",
      "N6":"BSB2",
      "N8":"P11",
      "N9":"P12",
      "nasDVG":"SPNV",
      "nasHVG":"SPNV",
      "nasMBB":"SPNV",
      "nasMBT":"SPNV",
      "nasMBW":"P20",
      "NBRB12":"RB8",
      "NBRB25":"RB8",
      "NBRB26":"RB8",
      "NBRB27":"RB8",
      "NBRB35":"RB8",
      "NBRB36":"RB8",
      "NBRB54":"RB8",
      "NBRB60":"RB8",
      "NBRB61":"RB8",
      "NBRB62":"RB8",
      "NBRB63":"RB8",
      "NB":"RB8",
      "NWBus":"NWB",
      "NX":"RB9",
      "NXRB":"RB9",
      "NXRE":"RB9",
      "NY":"MSM",
      "NYUEX":"UEX",
      "NZ":"RE5",
      "O0":"NBE",
      "O7":"ÖBA",
      "O9":"OPB",
      "O9X":"OPX",
      "OD":"SOE",
      "omp12":"OMP",
      "ompBUS":"OMP",
      "ovfOVF":"SPNV",
      "OWBus":"ODEG",
      "OW":"ODEG",
      "OWRB13":"ODEG",
      "OWRB14":"ODEG",
      "OWRB33":"ODEG",
      "OWRB41":"ODEG",
      "OWRB46":"ODEG",
      "OWRB51":"ODEG",
      "OWRB64":"ODEG",
      "OWRB65":"ODEG",
      "OWRE10":"ODEG",
      "OWRE2":"ODEG",
      "OWRE4":"ODEG",
      "OWRE9":"ODEG",
      "PB":"RB10",
      "R0":"ENO",
      "R1":"ME2",
      "R2":"ERB",
      "R2RB":"ERB",
      "R2RE":"ERB",
      "R4RH":"VIA",
      "R4":"VIA",
      "R4WEST":"VIA",
      "R7":"HzL",
      "rabRAB":"RAB3",
      "rbgAST":"SBG2",
      "rbgFMO":"SPNV",
      "rbgRBS":"RBS2",
      "rbgRVs":"RVS2",
      "rbgSBG":"SBG2",
      "rbgSEV":"Bus3",
      "rbrSEV":"SPNV",
      "RC":"AZS",
      "RD":"VBG1",
      "rmpRSG":"SPNV",
      "rmpUBB":"SPNV",
      "RS":"RSDG",
      "RW":"PRE",
      "S0":"DPN",
      "S1":"DPN",
      "S6":"SWE1",
      "S7":"DPN",
      "S9":"as",
      "SAB":"SAB",
      "SB":"STB",
      "SBX":"STx",
      "SD":"DPN",
      "SW":"DPN",
      "swgSEV":"DPN",
      "T8":"BOB",
      "TRI":"TRI",
      "TR":"RB11",
      "UW":"UBB1",
      "V6RB":"RB12",
      "V6RE":"RE6",
      "V6":"vlx",
      "V9":"P15",
      "vgsBar":"vgsBar",
      "vms001":"SPNV",
      "vmsvms":"SPNV",
      "vuVAB":"VU",
      "vvsSEV":"Bus3",
      "vvsWEG":"WEG7",
      "VW":"ODEG",
      "W0":"WDR",
      "W1":"WEE",
      "W2":"Dab",
      "W3":"WFB",
      "W6":"WTB",
      "W8":"P16",
      "W9":"WBA",
      "X1":"erx",
      "X2":"erx",
      "Y0":"SCH2",
      "Y8":"BRB1",
      "Z8":"BZB",
      "Z9":"P18",
      "ZB":"SPNV",
      "08": "sbahn-berlin"
    }

    self.pc_to_name = {
      "AB":"AB ABELLIO Rail Baden-Württemberg GmbH",
      "ABBW":"ABELLIO Rail Baden-Württemberg GmbH",
      "ABR1":"ABELLIO Rail NRW GmbH",
      "ABRM":"Abellio Rail Mitteldeutschland GmbH",
      "ag":"agilis",
      "AKN":"AKN Eisenbahn AG",
      "ALX":"alex - Die Länderbahn GmbH DLB",
      "AR":"ABELLIO Rail NRW GmbH1",
      "ARR3":"Arriva Danmark",
      "as":"agilis-Schnellzug",
      "AX":"BahnTouristikExpress",
      "AZS":"AUTOZUG Sylt",
      "BE":"Bentheimer Eisenbahn",
      "BLB":"Berchtesgadener Land Bahn",
      "BOB2":"Bodensee-Oberschwaben-Bahn",
      "BOB":"Bayerische Oberlandbahn",
      "BRB1":"Bayerische Regiobahn",
      "BSB2":"Breisgau-S-Bahn GmbH",
      "Bus1":"DB Fernverkehr Bus",
      "Bus3":"SEV Baden-Württemberg",
      "BZB":"Bayerische Zugspitzbahn",
      "CD1":"Ceske Drahy",
      "D4":"DB Fernverkehr AG",
      "Dab":"Daadetalbahn",
      "DB10":"DB Regio AG Baden-Württemberg",
      "DB11":"DB Regio AG Bayern",
      "DB12":"DB Regio AG Mitte Region Südwest",
      "DB3":"DB Regio AG",
      "DB5":"DB Regio AG Nordost",
      "DB6":"DB Regio AG Nord",
      "DB7":"DB Regio AG NRW",
      "DB8":"DB Regio AG Südost",
      "DB9":"DB Regio AG Mitte Region Hessen",
      "DBRM":"DB Regio Mitte",
      "DBRSBRM":"DB Regio AG S-Bahn Rhein-Main",
      "DELHA":"Delmenhorst-Harpstedter Eisenbahnhfreunde e.V",
      "DPN":"Nahreisezug",
      "DSB1":"Dänische Staatsbahnen",
      "D":"Sylt Shuttle Plus",
      "EB1":"Erfurter Bahn1",
      "EBx":"Erfurter Bahn Express",
      "EC":"DB/SBB/TI Eurocity Milano",
      "EGB":"DB RegioNetz Verkehrs GmbH Erzgebirgsbahn",
      "ENO":"enno",
      "ERB":"Eurobahn",
      "erx":"erixx",
      "EVB1":"EVB ELBE-WESER GmbH",
      "FEG":"Freiberger Eisenbahngesellschaft",
      "FLX":"FlixTrain",
      "GAMEX":"Go-Ahead Baden-Württemberg GmbH",
      "GBB1":"DB RegioNetz Verkehrs GmbH Gäubodenbahn",
      "GOAH":"Go-Ahead Verkehrsgesellschaft Deutschland mbH",
      "H4":"RegioTram",
      "HEX1":"Transdev Sachsen-Anhalt",
      "HKX":"Hamburg-Köln-Express",
      "HLB":"Hessische Landesbahn GmbH",
      "HZ":"HZPP",
      "HzL":"Hohenzollerische Landesbahn AG",
      "KD3":"Köln-Düsseldorfer Deutsche Rheinschifffahrt AG",
      "KHB":"DB RegioNetz Verkehrs GmbH Kurhessenbahn",
      "KTB":"Kandertalbahn",
      "KVG":"Kahlgrund-Verkehrs-Gesellschaft",
      "KVV":"Stadtbahn Karlsruhe SEV",
      "LEO":"Chiemgauer Lokalbahn",
      "LOC":"Locomore",
      "MAV":"MAV",
      "MBB1":"Mecklenburgische Bäderbahn Molli",
      "ME2":"metronom",
      "M":"Meridian",
      "MSB":"Mainschleifenbahn",
      "MSM":"MSM Partyzug",
      "NBE":"Nordbahn Eisenbahngesellschaft",
      "neg":"Norddeutsche Eisenbahn Gesellschaft",
      "NS":"Nederlandse Spoorwegen",
      "NWB":"NordWestBahn",
      "ÖBA":"Öchsle-Bahn-Betriebsgesellschaft mbH1",
      "ÖBB":"Österreichische Bundesbahnen",
      "OBS1":"DB RegioNetz Verkehrs GmbH Oberweisbacher Berg+Schwarzatalb",
      "ODEG":"Ostdeutsche Eisenbahn GmbH",
      "OMP":"Omnipart Verkehrsdienstleistungen GmbH",
      "OPB":"oberpfalzbahn - Die Länderbahn GmbH DLB",
      "ÖPO":"ÖBB-Postbus",
      "OPX":"oberpfalz-express - Die Länderbahn GmbH DLB",
      "P10":"Museumsbahn",
      "P11":"BayernBahn Betriebs-GmbH",
      "P12":"Rodachtalbahn",
      "P15":"Wanderbahn im Regental",
      "P16":"Staudenbahn",
      "P18":"Rhön-Zügle",
      "P20":"Mansfelder Bergwerksbahn1",
      "P2":"Brohltalbahn",
      "P3":"RuhrtalBahn",
      "P4":"Kasbachtalbahn",
      "P7":"Ilztalbahn",
      "PKP":"PKP Intercity",
      "PRE":"Pressnitztalbahn",
      "RAB3":"DB ZugBus Regionalverkehr Alb-Bodensee",
      "RB10":"Hanseatische Eisenbahn GmbH",
      "RB11":"MittelrheinBahn (Trans Regio)",
      "RB12":"vlexx",
      "RB2":"ABELLIO Rail Mitteldeutschland GmbH",
      "RB4":"Mitteldeutsche Regiobahn",
      "RB6":"Städtebahn Sachsen",
      "RB7":"cantus Verkehrsgesellschaft",
      "RB8":"NEB Niederbarnimer Eisenbahn",
      "RB9":"National Express",
      "RBS2":"Regiobus Stuttgart",
      "RE5":"DB Fernverkehr (Codesharing)",
      "RE6":"vlexx1",
      "RE":"ABELLIO Rail Mitteldeutschland GmbH1",
      "RSDG":"Regionalverkehre Start Deutschland GmbH",
      "RTB1":"Rurtalbahn",
      "RTB":"Eifel-Bördebahn",
      "RVS2":"Südwestbus1",
      "RZD":"RZD",
      "S3":"S-Bahn Hamburg",
      "S4":"REGIOBAHN",
      "SAB":"Schwäbische Alb-Bahn",
      "SBB1":"SBB GmbH",
      "SBB":"SBB",
      "SBG2":"Südbadenbus",
      "SBS1":"Schweizerische Bodensee-Schiffahrtsgesellschaft",
      "SCB":"SNCB",
      "SCF":"SNCF",
      "SCH2":"Adler-Schiffe",
      "SDG":"SDG Sächsische Dampfeisenbahngesellschaft mbH",
      "SE1":"ABELLIO Rail Mitteldeutschland GmbH2",
      "SOB":"DB RegioNetz Verkehrs GmbH Südostbayernbahn",
      "SOE":"Sächsisch-Oberlausitzer Eisenbahngesellschaft",
      "SPNV":"DB-Nahverkehr",
      "STB":"Süd-Thüringen-Bahn",
      "STx":"Süd-Thüringen-Bahn Express",
      "SWE1":"Südwestdeutsche Verkehrs-AG",
      "SWX":"SÜWEX",
      "SZ":"Slovenske zeleznice",
      "THU1":"THURBO",
      "TI1":"Trenitalia",
      "TL3":"trilex - Die Länderbahn GmbH DLB1",
      "TL4":"trilex  - Die Länderbahn GmbH DLB",
      "TLX":"trilex-express - Die Länderbahn GmbH DLB",
      "TRI":"TRI Train Rental GmbH",
      "UBB1":"Usedomer Bäderbahn1",
      "UEX":"Nachtzug",
      "UNB":"Unbekannt",
      "URh":"Untersee und Rhein",
      "VBG1":"vogtlandbahn - Die Länderbahn GmbH DLB",
      "VEN":"Rhenus Veniro",
      "vgsBar":"vgsBar",
      "VIA":"VIAS Rail GmbH",
      "vlx":"vlexx2",
      "VU":"Verkehrsgesellschaft Untermain",
      "WBA":"waldbahn - Die Länderbahn GmbH DLB",
      "WDR":"Wyker Dampfschiffs-Reederei Föhr-Amrum GmbH",
      "WEE":"Weser Ems Eisenbahn",
      "WEG7":"Württembergische Eisenbahn-Gesellschaft mbH",
      "WFB":"DB RegioNetz Verkehrs GmbH Westfrankenbahn",
      "WTB":"Wutachtalbahn",
      "ZSS":"ZSSK",
      "sbahn-berlin": "S-Bahn Berlin"
    }
    
    self.operator_mark_colors = {
      "AB": '#d5012e',
      "ABBW": '#d5012e',
      "ABR1": '#d5012e',
      "ABRM": '#d5012e',
      "ag": None,
      "AKN": None,
      "ALX": None,
      "AR": None,
      "ARR3": None,
      "as": None,
      "AX": None,
      "AZS": None,
      "BE": None,
      "BLB": None,
      "BOB2": None,
      "BOB": None,
      "BRB1": None,
      "BSB2": None,
      "Bus1": '#ff0000',
      "Bus3": None,
      "BZB": None,
      "CD1": None,
      "D4": '#ff0000',
      "Dab": None,
      "DB10": '#ff0000',
      "DB11": '#ff0000',
      "DB12": '#ff0000',
      "DB3": '#ff0000',
      "DB5": '#ff0000',
      "DB6": '#ff0000',
      "DB7": '#ff0000',
      "DB8": '#ff0000',
      "DB9": '#ff0000',
      "DBRM": None,
      "DBRSBRM": None,
      "DELHA": None,
      "DPN": None,
      "DSB1": None,
      "D": None,
      "EB1": None,
      "EBx": None,
      "EC": None,
      "EGB": None,
      "ENO": None,
      "ERB": None,
      "erx": None,
      "EVB1": None,
      "FEG": None,
      "FLX": None,
      "GAMEX": '#ffd400',
      "GBB1": None,
      "GOAH": '#ffd400',
      "H4": None,
      "HEX1": None,
      "HKX": None,
      "HLB": None,
      "HZ": None,
      "HzL": None,
      "KD3": None,
      "KHB": None,
      "KTB": None,
      "KVG": None,
      "KVV": None,
      "LEO": None,
      "LOC": None,
      "MAV": None,
      "MBB1": None,
      "ME2": None,
      "M": None,
      "MSB": None,
      "MSM": None,
      "NBE": None,
      "neg": None,
      "NS": None,
      "NWB": None,
      "ÖBA": None,
      "ÖBB": '#e2002a',
      "OBS1": None,
      "ODEG": '#faa61a',
      "OMP": None,
      "OPB": None,
      "ÖPO": None,
      "OPX": None,
      "P10": None,
      "P11": None,
      "P12": None,
      "P15": None,
      "P16": None,
      "P18": None,
      "P20": None,
      "P2": None,
      "P3": None,
      "P4": None,
      "P7": None,
      "PKP": '#002664',
      "PRE": None,
      "RAB3": '#f01414',
      "RB10": None,
      "RB11": None,
      "RB12": None,
      "RB2": None,
      "RB4": None,
      "RB6": None,
      "RB7": None,
      "RB8": None,
      "RB9": None,
      "RBS2": None,
      "RE5": '#ff0000',
      "RE6": None,
      "RE": None,
      "RSDG": None,
      "RTB1": None,
      "RTB": None,
      "RVS2": None,
      "RZD": None,
      "S3": None,
      "S4": None,
      "SAB": None,
      "SBB1": '#ec0000',
      "SBB": '#ec0000',
      "SBG2": None,
      "SBS1": None,
      "SCB": None,
      "SCF": None,
      "SCH2": None,
      "SDG": None,
      "SE1": None,
      "SOB": None,
      "SOE": None,
      "SPNV": None,
      "STB": None,
      "STx": None,
      "SWE1": None,
      "SWX": None,
      "SZ": None,
      "THU1": None,
      "TI1": None,
      "TL3": None,
      "TL4": None,
      "TLX": None,
      "TRI": None,
      "UBB1": None,
      "UEX": None,
      "UNB": None,
      "URh": None,
      "VBG1": None,
      "VEN": None,
      "vgsBar": None,
      "VIA": None,
      "vlx": None,
      "VU": None,
      "WBA": None,
      "WDR": None,
      "WEE": None,
      "WEG7": None,
      "WFB": '#ff0000',
      "WTB": None,
      "ZSS": None,
      "sbahn-berlin": None,
    }

    self.line_main_colors = {
      'sbahn-berlin': {
        'S1': '#db639a',
        'S2': '#016d2f',
        'S25': '#016d2f',
        'S26': '#016d2f',
        'S3': '#0160a5',
        'S41': '#ab4e31',
        'S42': '#cc591d',
        'S45': '#cd934e',
        'S46': '#cd934e',
        'S47': '#cd934e',
        'S5': '#ef6919',
        'S7': '#77659e',
        'S75': '#77659e',
        'S8': '#5ba125',
        'S85': '#5ba125',
        'S9': '#95203e',
      },
      'DB10': {
        'S1': '#5c8e3c',
        'S2': '#dc022c',
        'S3': '#f4aa04',
        'S4': '#0c66b3',
        'S5': '#04a9e3',
        'S6': '#8b6204',
        'S60': '#748d20',
      },
      'S3': {
        'S1': '#018d2a',
        'S11': '#018d2a',
        'S2': '#b30b33',
        'S21': '#b30b33',
        'S3': '#4c1f64',
        'S31': '#4c1f64',
      },
      'DB6': {
        'S1': '#836caa',
        'S2': '#007a3c',
        'S21': '#007a3c',
        'S3': '#cb68a6',
        'S4': '#9a2a47',
        'S5': '#f18700',
        'S51': '#f18700',
        'S6': '#004f9e',
        'S7': '#afca26',
        'S8': '#009ad9',
      },
      'DB11': {
        'S1': '#1ab3e2',
        'S2': '#71bf44',
        'S20': '#f05a73',
        'S3': '#7b107d',
        'S4': '#ee1c25',
        'S6': '#008a51',
        'S7': '#963833',
        'S8': '#000000',
      },
      'DBRSBRM': {
        'S1': '#0480b7',
        'S2': '#ff0000',
        'S3': '#019377',
        'S4': '#ffcc00',
        'S5': '#7f3107',
        'S6': '#f47922',
        'S7': '#01220e',
        'S8': '#7fc31c',
        'S9': '#81017e',
      },
      'DB12': {
        'S1': '#ec192e',
        'S2': '#2960b5',
        'S3': '#fcd804',
        'S33': '#f3c3c4',
        'S39': '#eaeaea',
        'S4': '#1a9d47',
        'S5': '#f47a14',
        'S51': '#f8a20d',
        'S6': '#27c9f5',
        'S9': '#7ac547',
      },
      'DB7': {
        'S1': '#0b9a33',
        'S2': '#006db6',
        'S28': '#717676',
        'S3': '#ffff00',
        'S4': '#ef7c00',
        'S5': '#fbef6d',
        'S6': '#dc052d',
        'S68': '#14bae6',
        'S7': '#14bae6',
        'S8': '#b03303',
        'S9': '#c7007f',
        'S11': '#ffed8d',
        'S12': '#61af20',
        'S19': '#2d6c7e',
        'S23': '#8b3c59',
      }
    }

    self.type_main_colors = {
      'STR': '#6a6a6a',
      'Bus': '#62b9c3',
    }

    self.type_mark_colors = {
      'U': '#014983',
      'S': '#018448',
    }

    self.type_text_colors = {
      'STR': '#f8f8f8',
      'Bus': '#f8f8f8',
    }
    
  def to_datetime(self, date_s):
    return multimodal_functions.time_to_utc(datetime.strptime(date_s, '%y%m%d%H%M'), multimodal_functions.TIMEZONE_DE)

  def time_to_station(self, expected_time):
    current_time = multimodal_functions.timestamp()
  
    try:
      time_to_station = int(expected_time - current_time)
      if (expected_time < current_time):
        time_to_station = int(current_time - expected_time) * -1
      return time_to_station

    except:
      return None

  def current_date_strings(self):
    timestamp = multimodal_functions.timestamp(multimodal_functions.TIMEZONE_DE)

    date_s = datetime.utcfromtimestamp(timestamp).strftime("%y%m%d")
    hour_s = datetime.utcfromtimestamp(timestamp).strftime("%H")

    timestamp2 = timestamp + multimodal_functions.HOUR_SECONDS
   
    date2_s = datetime.utcfromtimestamp(timestamp2).strftime("%y%m%d")
    hour2_s = datetime.utcfromtimestamp(timestamp2).strftime("%H")

    return date_s, hour_s, date2_s, hour2_s

  def status_verbose(self, status_short):
    status_a = {
      'a': 'added',
      'c': 'cancelled',
      'p': 'planned',
    }
    try:
      return status_a[status_short]
    except:
      return status_short
    
  def trip_type_verbose(self, status_short):
    status_a = {
      'a': 'added',
      'c': 'cancelled',
      'p': 'planned',
      'e': 'replacement',
      's': 'special',
    }
    try:
      return status_a[status_short]
    except:
      return status_short

  def message_type_verbose(self, type_short):
    type_a = {
      'h': 'him',             #A HIM message (generated through the Hafas Information Manager).
      'q': 'quality',         #A message about a quality change.
      'f': 'free_text',       #A free text message.
      'd': 'cause_of_delay',  #A message about the cause of a delay.
      'i': 'ibis', #An IBIS message (generated from IRIS-AP).
      'u': 'unassigned_ibis', #An IBIS message (generated from IRIS-AP) not yet assigned to a train.
      'r': 'disruption', #A major disruption.
      'w': 'car_location', #Wagenstand
      'c': 'connection', #Connection
    }

    try:
      return type_a[type_short]
    except:
      return type_short

  def filter_flag_verbose(self, type_short):
    type_a = {
      'D': 'external',  
      'F': 'long_distance',
      'N': 'regional',
      'S': 'city',
    }

    try:
      return type_a[type_short]
    except:
      return type_short
      

  def message_code_verbose(self, type_short):
    type_a = {
      '00': 'keine Verspätungsbegründung', #R, Begründung löschen
      '02': 'Polizeiliche Ermittlung', #R, BPOL/Polizei
      '03': 'Feuerwehreinsatz an der Strecke', #R, Feuer
      '04': 'kurzfristiger Personalausfall', #R, Personalausfall
      '05': 'ärztliche Versorgung eines Fahrgastes', #R, Notarzt am Zug
      '06': 'Betätigen der Notbremse', #R, Notbremse
      '07': 'Personen im Gleis', #R, Personen im Gl.
      '08': 'Notarzteinsatz am Gleis', #R, Personenunfall
      '09': 'Streikauswirkungen', #R, Streik
      '10': 'Tiere im Gleis', #R, Tiere
      '11': 'Unwetter', #R, Unwetter
      '12': 'Warten auf ein verspätetes Schiff', #R, Anschluss Schiff
      '13': 'Pass- und Zollkontrolle', #R, Zoll
      '14': 'Technische Störung am Bahnhof', #R, Technische Störung am Bahnhof
      '15': 'Beeinträchtigung durch Vandalismus', #R, Vandalismus
      '16': 'Entschärfung einer Fliegerbombe', #R, Fliegerbombe
      '17': 'Beschädigung einer Brücke', #R, Brückenbeschäd.
      '18': 'umgestürzter Baum im Gleis', #R, Baum im Gleis
      '19': 'Unfall an einem Bahnübergang', #R, BÜ-Unfall
      '20': 'Tiere im Gleis', #R, Tiere(Wild) im Gleis
      '21': 'Warten auf Fahrgäste aus einem anderen Zug', #R, Anschluss Zug
      '22': 'Witterungsbedingte Störung', #R, Wetter
      '23': 'Feuerwehreinsatz auf Bahngelände', #R, Feuer Bahngelände
      '24': 'Verspätung im Ausland', #R, Ausland
      '25': 'Warten auf weitere Wagen', #R, Flügel/Kurswagen
      '28': 'Gegenstände im Gleis', #R, Gegenst. im Gl.
      '29': 'Ersatzverkehr mit Bus ist eingerichtet', #R, Ersatzverkehr
      '31': 'Bauarbeiten', #R, Bauarbeiten
      '32': 'Verzögerung beim Ein-/Ausstieg', #R, Haltezeit
      '33': 'Oberleitungsstörung', #R, Oberleitung
      '34': 'Signalstörung', #R, Signalstörung
      '35': 'Streckensperrung', #R, Streckensperrung
      '36': 'technische Störung am Zug', #R, techn. Stör. Zug
      '38': 'technische Störung an der Strecke', #R, techn. Stör.Strecke
      '39': 'Anhängen von zusätzlichen Wagen', #R, Zusatzwagen
      '40': 'Stellwerksstörung /-ausfall', #R, Stellwerk
      '41': 'Störung an einem Bahnübergang', #R, BÜ-Störung
      '42': 'außerplanmäßige Geschwindigkeitsbeschränkung', #R, La-Stelle/EBA
      '43': 'Verspätung eines vorausfahrenden Zuges', #R, Zugfolge/Abstand
      '44': 'Warten auf einen entgegenkommenden Zug', #R, Kreuzung
      '45': 'Überholung', #R, Überholung
      '46': 'Warten auf freie Einfahrt', #R, besetzte Gleise
      '47': 'verspätete Bereitstellung des Zuges', #R, Bereitstellung
      '48': 'Verspätung aus vorheriger Fahrt', #R, Wende/Vorleistung
      '55': 'technische Störung an einem anderen Zug', #R, techn. Stör. Folge
      '56': 'Warten auf Fahrgäste aus einem Bus', #R, Anschluss Bus
      '57': 'Zusätzlicher Halt zum Ein-/Ausstieg für Reisende', #R, Zus. Halt
      '58': 'Umleitung des Zuges', #R, Umleitung
      '59': 'Schnee und Eis', #R, Schnee und Eis
      '60': 'Reduzierte Geschwindigkeit wegen Sturm', #R, Geschw./Sturm
      '61': 'Türstörung', #R, Türstörung
      '62': 'behobene technische Störung am Zug', #R, Stör. Zug behoben
      '63': 'technische Untersuchung am Zug', #R, techn. Untersuchung
      '64': 'Weichenstörung', #R, Weichenstörung
      '65': 'Erdrutsch', #R, Erdrutsch
      '66': 'Hochwasser', #R, Hochwasser
      '70': 'WLAN im gesamten Zug nicht verfügbar', #Q, WLAN Zug (q)
      '71': 'WLAN in einem/mehreren Wagen nicht verfügbar', #Q, WLAN Wagen (q)
      '72': 'Info-/Entertainment nicht verfügbar', #Q, Info-/Entertainment (q)
      '73': 'Heute: Mehrzweckabteil vorne', #Q, R: Mehrzweck vorn (q)
      '74': 'Heute: Mehrzweckabteil hinten', #Q, R: Mehrzweck hinten (q)
      '75': 'Heute: 1. Klasse vorne', #Q, R: 1 Kl. vorn (q)
      '76': 'Heute: 1. Klasse hinten', #Q, R: 1 Kl. hinten (q)
      '77': 'ohne 1. Klasse', #Q, ohne 1. Kl. (q)
      '79': 'ohne Mehrzweckabteil', #Q, R: ohne Mehrzweck (q)
      '80': 'andere Reihenfolge der Wagen', #Q, Abw. Reihung (q)
      '82': 'mehrere Wagen fehlen', #Q, Wagen fehlen (q)
      '83': 'Störung fahrzeuggebundene Einstiegshilfe', #Q, PRM-Einstiegshilfe
      '84': 'Zug verkehrt richtig gereiht', #Q, Reihung ok (q)
      '85': 'ein Wagen fehlt', #Q, Wagen fehlt (q)
      '86': 'gesamter Zug ohne Reservierung', #Q, RES: Zug (q)
      '87': 'einzelne Wagen ohne Reservierung', #Q, RES: Wagen (q)
      '88': 'keine Qualitätsmängel', #Q, Qualität ok (q)
      '89': 'Reservierungen sind wieder vorhanden', #Q, RES: ok (q)
      '90': 'kein gastronomisches Angebot', #Q, Bewirtschaftung fehlt (q)
      '91': 'fehlende Fahrradbeförderung', #Q, fehlende Fahrradbef. (q)
      '92': 'Eingeschränkte Fahrradbeförderung', #Q, eingeschr. Fahrradbef. (q)
      '93': 'keine behindertengerechte Einrichtung', #Q, PRM-Einrichtung (q)
      '94': 'Ersatzbewirtschaftung', #Q, Bewirtschaftung Ersatz Caddy/Abteil
      '95': 'Ohne behindertengerechtes WC', #Q, PRM-WC (q)
      '96': 'Überbesetzung mit Kulanzleistungen', #Q, Überbesetzung Kulanz
      '97': 'Überbesetzung ohne Kulanzleistungen', #Q, Überbes. ohne Kulanz
      '98': 'sonstige Qualitätsmängel', #Q, sonstige Q-Mängel
      '99': 'Verzögerungen im Betriebsablauf', #R, Sonstige Gründe
    }

    try:
      return type_a[type_short]
    except:
      return ''

  def trip_template(self):
    return {
      'station_name': '',
      'trip_id': '',
      'trip_type': '',
      'owner': '',
      'service_type': '',
      'service_number': '',
      'service_mode': '',
      'arrival_planned_time': None,
      'arrival_changed_time': None,
      'planned_platform': '',
      'changed_platform': '',
      'planned_status': '',
      'changed_status': '',
      'line_id': '',
      'previous_calling_points': [],
      'changed_previous_calling_points': [],
      'arrival_hidden': False,
      'messages': {},
      'departure_planned_time': None,
      'departure_changed_time': None,
      'subsequent_calling_points': [],
      'changed_subsequent_calling_points': [],
      'referenced_trips': {},
      'departure_hidden': False,
      'departure_seconds': -21600,
      'arrival_seconds': -21600,
      'destination_name': '',
      'cancelled': False,
      'line_color': 'grey', 
      'mode_color': 'grey',
    }

  def to_mode(self, service_mode, service_type):
    if service_mode == 'city' and service_type == 'S':
      return 's-bahn'
    if service_type == 'Bus':
      return 'bus'
    return 'national-rail'

  def to_icon(self, service_type):
    icons = {
      'bus': 'de_bus',
      'ec': 'de_ec',
      'est': 'de_est',
      'ic': 'de_ic',
      'ice': 'de_ice',
      'rb': 'de_rb',
      're': 'de_re',
      's': 'de_s',
      'str': 'de_str',
      'tgv': 'de_tgv',
      'u': 'de_u',
    }

    if service_type in icons:
      return icons[service_type]

    return None

  def to_line_operator(self, owner):
    if owner in self.owner_to_pc:
      pc = self.owner_to_pc[owner]
      if pc in self.pc_to_name:
        return self.pc_to_name[pc]

    return ''

  def get_colors(self, owner, line_id, service_type, service_mode):
    main_color = None
    mark_color = None
    text_color = None
    agency = None

    if owner in self.owner_to_pc:
      agency = self.owner_to_pc[owner]

      try:
        main_color = self.line_main_colors[agency]["%s%s" % (service_type, line_id)]
      except:
        pass

    if not main_color and service_type in self.type_main_colors:
      main_color = self.type_main_colors[service_type]

    if service_type in self.type_mark_colors:
      mark_color = self.type_mark_colors[service_type]

    if not mark_color and agency in self.operator_mark_colors:
      mark_color = self.operator_mark_colors[agency]

    if service_type in self.type_text_colors:
      text_color = self.type_text_colors[service_type]

    if not main_color:
      main_color = 'grey'

    if not text_color:
      text_color = 'white'

    return main_color, mark_color, text_color


  def cleanup_destination(self, destination_name):
    if not destination_name or len(destination_name) < 1:
      return ""

    for station_type in ['(S)', '(S-Bahn)']:
      if destination_name.endswith(station_type):
        destination_name = destination_name[:-len(station_type)]

    return destination_name.strip()

  def create_message(self, m):
    message = {'id': m['id'], 'valid_timeframe': False, 'valid_from': None, 'valid_to': None}
    if 't' in m:
      message['type'] = self.message_type_verbose(m['t'])
    if 'pr' in m:
      message['priority'] = self.message_type_verbose(m['pr'])  #1=high,2=medium,3=low,4=expired
    if 'c' in m:
      message['code'] = m['c']
      message['code_text'] = self.message_code_verbose(m['c'])
    if 'from' in m:
      message['valid_from'] = self.to_datetime(m['from'])
    if 'to' in m:
      message['valid_to'] = self.to_datetime(m['to'])
    if 'ts' in m:
      message['timestamp'] = self.to_datetime(m['ts'])
    if 'cat' in m:
      message['category'] = m['cat']

    if message['valid_from'] and message['valid_to']:
      current_time = multimodal_functions.timestamp()
      message['valid_timeframe'] = message['valid_from'] <= current_time and message['valid_to'] >= current_time
    elif message['valid_from'] == None and message['valid_to'] == None:
      message['valid_timeframe'] = True  #No specified times means must be always valid, right?

    return message


  def update_trip(self, trip, tr, station_name):
    trip['station_name'] = station_name
    trip['trip_id'] = tr['id']

    if 'tl' in tr:
      tl = tr['tl']
      trip['trip_type'] = self.trip_type_verbose(tl['t'])
      trip['owner'] = tl['o']
      trip['service_type'] = tl['c']
      trip['service_number'] = tl['n']
      if 'f' in tl:
        trip['service_mode'] = self.filter_flag_verbose(tl['f'])

    if 'ar' in tr:
      ar = tr['ar']
      if 'pt' in ar:
        trip['arrival_planned_time'] = self.to_datetime(ar['pt'])
      if 'ct' in ar:
        trip['arrival_changed_time'] = self.to_datetime(ar['ct'])
      if 'pp' in ar:
        trip['planned_platform'] = ar['pp']
      if 'cp' in ar:
        trip['changed_platform'] = ar['cp']
      if 'ps' in ar:
        trip['planned_status'] = self.status_verbose(ar['ps'])
      if 'cs' in ar:
        trip['changed_status'] = self.status_verbose(ar['cs'])
      if 'l' in ar:
        trip['line_id'] = ar['l']
      if 'ppth' in ar:  
        trip['previous_calling_points'] = ar['ppth'].split('|')
      if 'cpth' in ar:  
        trip['changed_previous_calling_points'] = ar['cpth'].split('|')
      if 'hi' in ar:
        trip['arrival_hidden'] = ar['hi'] == '1'
      if 'm' in ar:
        for m in ar['m']:
          message = self.create_message(m)
          trip['messages'][message['id']] = message

    if 'dp' in tr:
      dp = tr['dp']
      if 'pt' in dp:
        trip['departure_planned_time'] =  self.to_datetime(dp['pt'])
      if 'ct' in dp:
        trip['departure_changed_time'] = self.to_datetime(dp['ct'])
      if 'pp' in dp:
        trip['planned_platform'] = dp['pp']
      if 'cp' in dp:
        trip['changed_platform'] = dp['cp']
      if 'ps' in dp:
        trip['planned_status'] = self.status_verbose(dp['ps'])
      if 'cs' in dp:
        trip['changed_status'] = self.status_verbose(dp['cs'])
      if 'l' in dp:
        trip['line_id'] = dp['l']
      if 'ppth' in dp:  
        trip['subsequent_calling_points'] = dp['ppth'].split('|')
      if 'cpth' in dp:  
        trip['changed_subsequent_calling_points'] = dp['cpth'].split('|')
      if 'hi' in dp:
        trip['departure_hidden'] = dp['hi'] == '1'
      if 'm' in dp:
        for m in dp['m']:
          message = self.create_message(m)
          trip['messages'][message['id']] = message

    if 'm' in tr:
      for m in tr['m']:
        message = self.create_message(m)
        trip['messages'][message['id']] = message

    if 'ref' in tr:
      for ref in tr['ref']:
        if 'o' in  ref:
          rtl = ref
          rtrip = {}
          rtrip['trip_type'] = self.trip_type_verbose(rtl['t'])
          rtrip['owner'] = rtl['o']
          rtrip['service_type'] = rtl['c']
          rtrip['service_number'] = rtl['n']
          if 'f' in rtl:
            rtrip['service_mode'] = self.filter_flag_verbose(rtl['f'])

          trip['referenced_trips'][rtrip['owner']] = rtrip

    if trip['departure_planned_time']:
      trip['departure_seconds'] = self.time_to_station(trip['departure_planned_time'])
    if trip['departure_changed_time']:
      trip['departure_seconds'] = self.time_to_station(trip['departure_changed_time'])
    if trip['arrival_planned_time']:
      trip['arrival_seconds'] = self.time_to_station(trip['arrival_planned_time'])
    if trip['arrival_changed_time']:
      trip['arrival_seconds'] = self.time_to_station(trip['arrival_changed_time'])

    if len(trip['subsequent_calling_points']) > 0:
      trip['destination_name'] = trip['subsequent_calling_points'][-1]
    else:
      trip['destination_name'] = station_name

    if len(trip['previous_calling_points']) > 0:
      trip['origin_name'] = trip['previous_calling_points'][0]
    else:
      trip['origin_name'] = station_name

    trip['main_color'], trip['mark_color'], trip['text_color'] = self.get_colors(trip['owner'], trip['line_id'], trip['service_type'], trip['service_mode'])

  def get_trips(self, stop_point_id):
    date1, hour1, date2, hour2 = self.current_date_strings()

    client = DbahnClient()
    trips = []
    trips_m = {}

    result = client.get_departures_board_static(stop_point_id, date1, hour1)
    if not result:
      return None

    for tr in result['s']:
      trip = self.trip_template()
      self.update_trip(trip, tr, result['station'])
      trips.append(trip)
      trips_m[trip['trip_id']] = trip

    result = client.get_departures_board_static(stop_point_id, date2, hour2)
    if result:
      for tr in result['s']:
        trip = self.trip_template()
        self.update_trip(trip, tr, result['station'])
        if tr['id'] not in trips_m:
          trips.append(trip)
          trips_m[trip['trip_id']] = trip
    
    if len(trips) < 1:
      return []

    result = client.get_departures_board_changes(stop_point_id)
    if result:
      for tr in result['s']:
        if tr['id'] in trips_m:
          trip = trips_m[tr['id']]
          self.update_trip(trip, tr, result['station'])
          trips_m[trip['trip_id']] = trip
        elif 'tl' in tr:
          ttrip = self.trip_template()
          self.update_trip(ttrip, tr, result['station'])   
          if (ttrip['arrival_seconds'] < -180 and  ttrip['departure_seconds'] < -180) or (ttrip['arrival_seconds'] > 7200 and  ttrip['departure_seconds'] > 7200):
            continue
          trips.append(ttrip)

    return trips

  def r_get_departures(self, stop_point_id):
    print('r_get_departures - requesting station board for code:', stop_point_id)

    trips = self.get_trips(stop_point_id)
    if not trips:
      pyotherside.send("error", "dbahn", "r_get_arrivals", 'Error retrieving departures')
      return  

    services = []
    for tr in trips:
      if not tr['departure_planned_time']:
        continue
      current_time = multimodal_functions.timestamp()
      if (current_time - tr['departure_planned_time']) > 300:
        continue
      if tr['departure_changed_time'] and (current_time - tr['departure_changed_time']) > 180:
        continue

      calling_points = []
      for cp in tr['previous_calling_points']:
        calling_points.append(multimodal_structures.calling_point_entry({
          'module': 'dbahn',
          'title': self.cleanup_destination(cp),
          'calling_point_name': cp,
          'set_index': 0,
          'is_cancelled': True if tr['changed_previous_calling_points'] and cp not in tr['changed_previous_calling_points'] else False,
        }))

      calling_points.append(multimodal_structures.calling_point_entry({
        'module': 'dbahn',
        'title': self.cleanup_destination(tr['station_name']),
        'calling_point_name': tr['station_name'],
        'set_index': 0,
        'is_cancelled': False,
        'is_requesting_station': True,
        'time_to_station': tr['departure_seconds'],
        'time_expected': tr['departure_changed_time'] if tr['departure_changed_time'] else tr['departure_planned_time'],
      }))

      for cp in tr['subsequent_calling_points']:
        calling_points.append(multimodal_structures.calling_point_entry({
          'module': 'dbahn',
          'title': self.cleanup_destination(cp),
          'calling_point_name': cp,
          'set_index': 0,
          'is_cancelled': True if tr['changed_subsequent_calling_points'] and cp not in tr['changed_subsequent_calling_points'] else False,
        }))

      if len(calling_points) > 0:
        calling_points[0]['is_origin'] = True
        calling_points[-1]['is_destination'] = True

      services.append(multimodal_structures.timetable_entry({
        'module': 'dbahn',
        'service_id': tr['service_type']+tr['service_number'],
        'is_departure': True,
        'title': self.cleanup_destination(tr['destination_name']),
        'subtitle': tr['service_type'] + ' ' + tr['line_id'] if tr['service_type'] == 'Bus' else tr['service_type'] + tr['line_id'],
        'line_id': self.to_line_operator(tr['owner']),
        'line_name': tr['service_type'] + ' ' + tr['line_id'] if tr['service_type'] == 'Bus' else tr['service_type'] + tr['line_id'],
        'transport_mode': self.to_mode(tr['service_mode'], tr['service_type']),
        'time_to_station': tr['departure_seconds'],
        'time_delay': 0,
        'time_planned': tr['departure_planned_time'],
        'time_expected': tr['departure_changed_time'] if tr['departure_changed_time'] else tr['departure_planned_time'],
        'is_realtime_data': True,
        'is_delayed': False,
        'delay_reason': None,
        'is_cancelled': False,
        'cancel_reason': None,
        'platform_name': tr['changed_platform'] if tr['changed_platform'] else tr['planned_platform'],
        'platform_changed': True if tr['changed_platform'] else False,
        'main_color': tr['main_color'],
        'mark_color': tr['mark_color'],
        'text_color': tr['text_color'],
        'icon_name': self.to_icon(tr['service_type'].lower()),
        'messages': tr['messages'].values(),
        'calling_points': [calling_points],
      }))

    pyotherside.send("a_get_predictions", services)

  def r_get_arrivals(self, stop_point_id):
    print('r_get_arrivals - requesting station board for code:', stop_point_id)

    trips = self.get_trips(stop_point_id)
    if not trips:
      pyotherside.send("error", "dbahn", "r_get_arrivals", 'Error retrieving arrivals')
      return
      
    services = []
    for tr in trips:
      if not tr['arrival_planned_time']:
        continue
      current_time = multimodal_functions.timestamp()
      if (current_time - tr['arrival_planned_time']) > 300:
        continue
      if tr['arrival_changed_time'] and (current_time - tr['arrival_changed_time']) > 180:
        continue

      services.append(multimodal_structures.timetable_entry({
        'module': 'dbahn',
        'service_id': tr['service_type']+tr['service_number'],
        'is_departure': False,
        'title': self.cleanup_destination(tr['origin_name']),
        'subtitle': tr['service_type'] + ' ' + tr['line_id'] if tr['service_type'] == 'Bus' else tr['service_type'] + tr['line_id'],
        'line_id': self.to_line_operator(tr['owner']),
        'line_name': tr['service_type'] + ' ' + tr['line_id'] if tr['service_type'] == 'Bus' else tr['service_type'] + tr['line_id'],
        'transport_mode': self.to_mode(tr['service_mode'], tr['service_type']),
        'time_to_station': tr['arrival_seconds'],
        'time_delay': 0,
        'time_planned': tr['arrival_planned_time'],
        'time_expected': tr['arrival_changed_time'] if tr['arrival_changed_time'] else tr['arrival_planned_time'],
        'is_realtime_data': True,
        'is_delayed': False,
        'delay_reason': None,
        'is_cancelled': False,
        'cancel_reason': None,
        'platform_name': tr['changed_platform'] if tr['changed_platform'] else tr['planned_platform'],
        'platform_changed': True if tr['changed_platform'] else False,
        'main_color': tr['main_color'],
        'mark_color': tr['mark_color'],
        'text_color': tr['text_color'],
        'icon_name': self.to_icon(tr['service_type'].lower()),
        'messages': tr['messages'].values(),
      }))

    pyotherside.send("a_get_predictions", services)

dbahn_object = Dbahn()
