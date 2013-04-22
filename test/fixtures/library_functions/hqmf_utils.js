// #########################
// ###### PATIENT API #######
// #########################

/**
@namespace scoping into the hquery namespace
*/

var __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

this.hQuery || (this.hQuery = {});

/**
Converts a a number in UTC Seconds since the epoch to a date.
@param {number} utcSeconds seconds since the epoch in UTC
@returns {Date}
@function
@exports dateFromUtcSeconds as hQuery.dateFromUtcSeconds
*/


hQuery.dateFromUtcSeconds = function(utcSeconds) {
  return new Date(utcSeconds * 1000);
};

/**
@class Scalar - a representation of a unit and value
@exports Scalar as hQuery.Scalar
*/


hQuery.Scalar = (function() {

  function Scalar(json) {
    this.json = json;
  }

  Scalar.prototype.unit = function() {
    return this.json['unit'];
  };

  Scalar.prototype.value = function() {
    return this.json['value'];
  };

  return Scalar;

})();

/**
@class PhysicalQuantity - a representation of a physical quantity
@exports PhysicalQuantity as hQuery.PhysicalQuantity
*/


hQuery.PhysicalQuantity = (function() {

  function PhysicalQuantity(json) {
    this.json = json;
  }

  PhysicalQuantity.prototype.units = function() {
    return this.json['units'];
  };

  PhysicalQuantity.prototype.scalar = function() {
    return this.json['scalar'];
  };

  return PhysicalQuantity;

})();

/**
@class A code with its corresponding code system
@exports CodedValue as hQuery.CodedValue
*/


hQuery.CodedValue = (function() {
  /**
  @param {String} c value of the code
  @param {String} csn name of the code system that the code belongs to
  @constructs
  */

  function CodedValue(c, csn) {
    this.c = c;
    this.csn = csn;
  }

  /**
  @returns {String} the code
  */


  CodedValue.prototype.code = function() {
    return this.c;
  };

  /**
  @returns {String} the code system name
  */


  CodedValue.prototype.codeSystemName = function() {
    return this.csn;
  };

  /**
  Returns true if the contained code and codeSystemName match a code in the supplied codeSet.
  @param {Object} codeSet a hash with code system names as keys and an array of codes as values
  @returns {boolean}
  */


  CodedValue.prototype.includedIn = function(codeSet) {
    var code, codeSystemName, codes, _i, _len;
    for (codeSystemName in codeSet) {
      codes = codeSet[codeSystemName];
      if (this.csn === codeSystemName) {
        for (_i = 0, _len = codes.length; _i < _len; _i++) {
          code = codes[_i];
          if (code === this.c) {
            return true;
          }
        }
      }
    }
    return false;
  };

  return CodedValue;

})();

/**
Status as defined by value set 2.16.840.1.113883.5.14,
the ActStatus vocabulary maintained by HL7

@class Status
@augments hQuery.CodedEntry
@exports Status as hQuery.Status
*/


hQuery.Status = (function(_super) {
  var ABORTED, ACTIVE, CANCELLED, COMPLETED, HELD, NEW, NORMAL, NULLIFIED, OBSOLETE, SUSPENDED;

  __extends(Status, _super);

  function Status() {
    return Status.__super__.constructor.apply(this, arguments);
  }

  NORMAL = "normal";

  ABORTED = "aborted";

  ACTIVE = "active";

  CANCELLED = "cancelled";

  COMPLETED = "completed";

  HELD = "held";

  NEW = "new";

  SUSPENDED = "suspended";

  NULLIFIED = "nullified";

  OBSOLETE = "obsolete";

  Status.prototype.isNormal = function() {
    return this.c === NORMAL;
  };

  Status.prototype.isAborted = function() {
    return this.c === ABORTED;
  };

  Status.prototype.isActive = function() {
    return this.c === ACTIVE;
  };

  Status.prototype.isCancelled = function() {
    return this.c === CANCELLED;
  };

  Status.prototype.isCompleted = function() {
    return this.c === COMPLETED;
  };

  Status.prototype.isHeld = function() {
    return this.c === HELD;
  };

  Status.prototype.isNew = function() {
    return this.c === NEW;
  };

  Status.prototype.isSuspended = function() {
    return this.c === SUSPENDED;
  };

  Status.prototype.isNullified = function() {
    return this.c === NULLIFIED;
  };

  Status.prototype.isObsolete = function() {
    return this.c === OBSOLETE;
  };

  return Status;

})(hQuery.CodedValue);

/**
@class an Address for a person or organization
@exports Address as hQuery.Address
*/


hQuery.Address = (function() {

  function Address(json) {
    this.json = json;
  }

  /**
  @returns {Array[String]} the street addresses
  */


  Address.prototype.street = function() {
    return this.json['street'];
  };

  /**
  @returns {String} the city
  */


  Address.prototype.city = function() {
    return this.json['city'];
  };

  /**
  @returns {String} the State
  */


  Address.prototype.state = function() {
    return this.json['state'];
  };

  /**
  @returns {String} the postal code
  */


  Address.prototype.postalCode = function() {
    return this.json['zip'];
  };

  return Address;

})();

/**
@class An object that describes a means to contact an entity.  This is used to represent
phone numbers, email addresses,  instant messaging accounts etc.
@exports Telecom as hQuery.Telecom
*/


hQuery.Telecom = (function() {

  function Telecom(json) {
    this.json = json;
  }

  /**
  @returns {String} the type of telecom entry, phone, sms, email ....
  */


  Telecom.prototype.type = function() {
    return this.json['type'];
  };

  /**
  @returns {String} the value of the entry -  the actual phone number , email address , ....
  */


  Telecom.prototype.value = function() {
    return this.json['value'];
  };

  /**
  @returns {String} the use of the entry. Is it a home, office, .... type of contact
  */


  Telecom.prototype.use = function() {
    return this.json['use'];
  };

  /**
  @returns {Boolean} is this a preferred form of contact
  */


  Telecom.prototype.preferred = function() {
    return this.json['preferred'];
  };

  return Telecom;

})();

/**
@class an object that describes a person.  includes a persons name, addresses, and contact information
@exports Person as hQuery.Person
*/


hQuery.Person = (function() {

  function Person(json) {
    this.json = json;
  }

  /**
   @returns {String} the given name of the person
  */


  Person.prototype.given = function() {
    return this.json['first'];
  };

  /**
   @returns {String} the last/family name of the person
  */


  Person.prototype.last = function() {
    return this.json['last'];
  };

  /**
   @returns {String} the display name of the person
  */


  Person.prototype.name = function() {
    if (this.json['name']) {
      return this.json['name'];
    } else {
      return this.json['first'] + ' ' + this.json['last'];
    }
  };

  /**
   @returns {Array} an array of {@link hQuery.Address} objects associated with the patient
  */


  Person.prototype.addresses = function() {
    var address, list, _i, _len, _ref;
    list = [];
    if (this.json['addresses']) {
      _ref = this.json['addresses'];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        address = _ref[_i];
        list.push(new hQuery.Address(address));
      }
    }
    return list;
  };

  /**
  @returns {Array} an array of {@link hQuery.Telecom} objects associated with the person
  */


  Person.prototype.telecoms = function() {
    var tel, _i, _len, _ref, _results;
    _ref = this.json['telecoms'];
    _results = [];
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      tel = _ref[_i];
      _results.push(new hQuery.Telecom(tel));
    }
    return _results;
  };

  return Person;

})();

/**
@class an actor is either a person or an organization
@exports Actor as hQuery.Actor
*/


hQuery.Actor = (function() {

  function Actor(json) {
    this.json = json;
  }

  Actor.prototype.person = function() {
    if (this.json['person']) {
      return new hQuery.Person(this.json['person']);
    }
  };

  Actor.prototype.organization = function() {
    if (this.json['organization']) {
      return new hQuery.Organization(this.json['organization']);
    }
  };

  return Actor;

})();

/**
@class an Organization
@exports Organization as hQuery.Organization
*/


hQuery.Organization = (function() {

  function Organization(json) {
    this.json = json;
  }

  /**
  @returns {String} the id for the organization
  */


  Organization.prototype.organizationId = function() {
    return this.json['organizationId'];
  };

  /**
  @returns {String} the name of the organization
  */


  Organization.prototype.organizationName = function() {
    return this.json['name'];
  };

  /**
  @returns {Array} an array of {@link hQuery.Address} objects associated with the organization
  */


  Organization.prototype.addresses = function() {
    var address, list, _i, _len, _ref;
    list = [];
    if (this.json['addresses']) {
      _ref = this.json['addresses'];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        address = _ref[_i];
        list.push(new hQuery.Address(address));
      }
    }
    return list;
  };

  /**
  @returns {Array} an array of {@link hQuery.Telecom} objects associated with the organization
  */


  Organization.prototype.telecoms = function() {
    var tel, _i, _len, _ref, _results;
    _ref = this.json['telecoms'];
    _results = [];
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      tel = _ref[_i];
      _results.push(new hQuery.Telecom(tel));
    }
    return _results;
  };

  return Organization;

})();

/**
@class a Facility
@exports Organization as hQuery.Facility
*/


hQuery.Facility = (function(_super) {

  __extends(Facility, _super);

  function Facility(json) {
    this.json = json;
    if (this.json['code'] != null) {
      Facility.__super__.constructor.call(this, this.json['code']['code'], this.json['code']['codeSystem']);
    }
  }

  /**
  @returns {String} the name of the facility
  */


  Facility.prototype.name = function() {
    return this.json['name'];
  };

  /**
  @returns {Array} an array of {@link hQuery.Address} objects associated with the facility
  */


  Facility.prototype.addresses = function() {
    var address, list, _i, _len, _ref;
    list = [];
    if (this.json['addresses']) {
      _ref = this.json['addresses'];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        address = _ref[_i];
        list.push(new hQuery.Address(address));
      }
    }
    return list;
  };

  /**
  @returns {Array} an array of {@link hQuery.Telecom} objects associated with the facility
  */


  Facility.prototype.telecoms = function() {
    var tel, _i, _len, _ref, _results;
    _ref = this.json['telecoms'];
    _results = [];
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      tel = _ref[_i];
      _results.push(new hQuery.Telecom(tel));
    }
    return _results;
  };

  return Facility;

})(hQuery.CodedValue);

/**
@class represents a DateRange in the form of hi and low date values.
@exports DateRange as hQuery.DateRange
*/


hQuery.DateRange = (function() {

  function DateRange(json) {
    this.json = json;
  }

  DateRange.prototype.hi = function() {
    if (this.json['hi']) {
      return hQuery.dateFromUtcSeconds(this.json['hi']);
    }
  };

  DateRange.prototype.low = function() {
    return hQuery.dateFromUtcSeconds(this.json['low']);
  };

  return DateRange;

})();

/**
@class Class used to describe an entity that is providing some form of information.  This does not mean that they are
providing any treatment just that they are providing information.
@exports Informant as hQuery.Informant
*/


hQuery.Informant = (function() {

  function Informant(json) {
    this.json = json;
  }

  /**
  an array of hQuery.Person objects as points of contact
  @returns {Array}
  */


  Informant.prototype.contacts = function() {
    var contact, _i, _len, _ref, _results;
    _ref = this.json['contacts'];
    _results = [];
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      contact = _ref[_i];
      _results.push(new hQuery.Person(contact));
    }
    return _results;
  };

  /**
   @returns {hQuery.Organization} the organization providing the information
  */


  Informant.prototype.organization = function() {
    return new hQuery.Organization(this.json['organization']);
  };

  return Informant;

})();

/**
@class
@exports CodedEntry as hQuery.CodedEntry
*/


hQuery.CodedEntry = (function() {

  function CodedEntry(json) {
    this.json = json;
    if (this.json['time']) {
      this._date = hQuery.dateFromUtcSeconds(this.json['time']);
    }
    if (this.json['start_time']) {
      this._startDate = hQuery.dateFromUtcSeconds(this.json['start_time']);
    }
    if (this.json['end_time']) {
      this._endDate = hQuery.dateFromUtcSeconds(this.json['end_time']);
    }
    this._type = hQuery.createCodedValues(this.json['codes']);
    this._statusCode = this.json['status_code'];
    this.id = this.json['_id'];
    this.source_id = this.json['id'];
    this._freeTextType = this.json['description'];
  }

  /**
  Date and time at which the coded entry took place
  @returns {Date}
  */


  CodedEntry.prototype.date = function() {
    return this._date;
  };

  /**
  Date and time at which the coded entry started
  @returns {Date}
  */


  CodedEntry.prototype.startDate = function() {
    return this._startDate;
  };

  /**
  Date and time at which the coded entry ended
  @returns {Date}
  */


  CodedEntry.prototype.endDate = function() {
    return this._endDate;
  };

  /**
  Tries to find a single point in time for this entry. Will first return date if it is present,
  then fall back to startDate and finally endDate
  @returns {Date}
  */


  CodedEntry.prototype.timeStamp = function() {
    return this._date || this._startDate || this._endDate;
  };

  /**
  Determines whether the entry specifies a time range or not
  @returns {boolean}
  */


  CodedEntry.prototype.isTimeRange = function() {
    return (this._startDate != null) && (this._endDate != null);
  };

  /**
  Determines whether a coded entry contains sufficient information (code and at least 
  one time stamp) to be usable
  @returns {boolean}
  */


  CodedEntry.prototype.isUsable = function() {
    return this._type.length > 0 && (this._date || this._startDate || this._endDate);
  };

  /**
  An Array of CodedValues which describe what kind of coded entry took place
  @returns {Array}
  */


  CodedEntry.prototype.type = function() {
    return this._type;
  };

  /**
  A free text description of the type of coded entry
  @returns {String}
  */


  CodedEntry.prototype.freeTextType = function() {
    return this._freeTextType;
  };

  /**
  Status for this coded entry
  @returns {String}
  */


  CodedEntry.prototype.status = function() {
    if (this._statusCode != null) {
      if (this._statusCode['HL7 ActStatus'] != null) {
        return this._statusCode['HL7 ActStatus'][0];
      } else if (this._statusCode['SNOMED-CT'] != null) {
        switch (this._statusCode['SNOMED-CT'][0]) {
          case '55561003':
            return 'active';
          case '73425007':
            return 'inactive';
          case '413322009':
            return 'resolved';
        }
      }
    }
  };

  /**
  Status for this coded entry
  @returns {Hash} keys are code systems, values are arrays of codes
  */


  CodedEntry.prototype.statusCode = function() {
    return this._statusCode;
  };

  /**
  Returns true if any of this entry codes match a code in the supplied codeSet.
  @param {Object} codeSet a hash with code system names as keys and an array of codes as values
  @returns {boolean}
  */


  CodedEntry.prototype.includesCodeFrom = function(codeSet) {
    var codedValue, _i, _len, _ref;
    _ref = this._type;
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      codedValue = _ref[_i];
      if (codedValue.includedIn(codeSet)) {
        return true;
      }
    }
    return false;
  };

  /**
  @returns {Boolean} whether the entry was negated
  */


  CodedEntry.prototype.negationInd = function() {
    return this.json['negationInd'] || false;
  };

  /**
  Returns the values of the result. This will return an array that contains
  PhysicalQuantity or CodedValue objects depending on the result type.
  @returns {Array} containing either PhysicalQuantity and/or CodedValues
  */


  CodedEntry.prototype.values = function() {
    var value, values, _i, _len, _ref;
    values = [];
    if (this.json['values']) {
      _ref = this.json['values'];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        value = _ref[_i];
        if (value['scalar'] != null) {
          values.push(new hQuery.PhysicalQuantity(value));
        } else {
          values.push(hQuery.createCodedValues(values));
        }
      }
    }
    return values;
  };

  /**
  Indicates the reason an entry was negated.
  @returns {hQuery.CodedValue}   Used to indicate reason an immunization was not administered.
  */


  CodedEntry.prototype.negationReason = function() {
    if (this.json['negationReason'] && this.json['negationReason']['code'] && this.json['negationReason']['codeSystem']) {
      return new hQuery.CodedValue(this.json['negationReason']['code'], this.json['negationReason']['codeSystem']);
    } else {
      return null;
    }
  };

  return CodedEntry;

})();

/**
@class Represents a list of hQuery.CodedEntry instances. Offers utility methods for matching
entries based on codes and date ranges
@exports CodedEntryList as hQuery.CodedEntryList
*/


hQuery.CodedEntryList = (function(_super) {

  __extends(CodedEntryList, _super);

  function CodedEntryList() {
    this.push.apply(this, arguments);
  }

  /**
  Push the supplied entry onto this list if it is usable
  @param {CodedEntry} a coded entry that should be added to the list if it is usable
  */


  CodedEntryList.prototype.pushIfUsable = function(entry) {
    if (entry.isUsable()) {
      return this.push(entry);
    }
  };

  /**
  Return the number of entries that match the
  supplied code set where those entries occur between the supplied time bounds
  @param {Object} codeSet a hash with code system names as keys and an array of codes as values
  @param {Date} start the start of the period during which the entry must occur, a null value will match all times
  @param {Date} end the end of the period during which the entry must occur, a null value will match all times
  @param {boolean} includeNegated whether the returned list of entries should include those that have been negated
  @return {CodedEntryList} the matching entries
  */


  CodedEntryList.prototype.match = function(codeSet, start, end, includeNegated) {
    var afterStart, beforeEnd, cloned, entry, _i, _len;
    if (includeNegated == null) {
      includeNegated = false;
    }
    cloned = new hQuery.CodedEntryList();
    for (_i = 0, _len = this.length; _i < _len; _i++) {
      entry = this[_i];
      afterStart = !start || entry.timeStamp() >= start;
      beforeEnd = !end || entry.timeStamp() <= end;
      if (afterStart && beforeEnd && entry.includesCodeFrom(codeSet) && (includeNegated || !entry.negationInd())) {
        cloned.push(entry);
      }
    }
    return cloned;
  };

  /**
  Return a new list of entries that is the result of concatenating the passed in entries with this list
  @return {CodedEntryList} the set of concatenated entries
  */


  CodedEntryList.prototype.concat = function(otherEntries) {
    var cloned, entry, _i, _j, _len, _len1;
    cloned = new hQuery.CodedEntryList();
    for (_i = 0, _len = this.length; _i < _len; _i++) {
      entry = this[_i];
      cloned.push(entry);
    }
    for (_j = 0, _len1 = otherEntries.length; _j < _len1; _j++) {
      entry = otherEntries[_j];
      cloned.push(entry);
    }
    return cloned;
  };

  /**
  Match entries with the specified statuses
  @return {CodedEntryList} the matching entries
  */


  CodedEntryList.prototype.withStatuses = function(statuses, includeUndefined) {
    var cloned, entry, _i, _len, _ref;
    if (includeUndefined == null) {
      includeUndefined = true;
    }
    if (includeUndefined) {
      statuses = statuses.concat([void 0, null]);
    }
    cloned = new hQuery.CodedEntryList();
    for (_i = 0, _len = this.length; _i < _len; _i++) {
      entry = this[_i];
      if (_ref = entry.status(), __indexOf.call(statuses, _ref) >= 0) {
        cloned.push(entry);
      }
    }
    return cloned;
  };

  /**
  Filter entries based on negation
  @param {Object} codeSet a hash with code system names as keys and an array of codes as values
  @return {CodedEntryList} negated entries
  */


  CodedEntryList.prototype.withNegation = function(codeSet) {
    var cloned, entry, _i, _len;
    cloned = new hQuery.CodedEntryList();
    for (_i = 0, _len = this.length; _i < _len; _i++) {
      entry = this[_i];
      if (entry.negationInd() && (!codeSet || (entry.negationReason() && entry.negationReason().includedIn(codeSet)))) {
        cloned.push(entry);
      }
    }
    return cloned;
  };

  /**
  Filter entries based on negation
  @return {CodedEntryList} non-negated entries
  */


  CodedEntryList.prototype.withoutNegation = function() {
    var cloned, entry, _i, _len;
    cloned = new hQuery.CodedEntryList();
    for (_i = 0, _len = this.length; _i < _len; _i++) {
      entry = this[_i];
      if (!entry.negationInd()) {
        cloned.push(entry);
      }
    }
    return cloned;
  };

  return CodedEntryList;

})(Array);

/**
@private
@function
*/


hQuery.createCodedValues = function(jsonCodes) {
  var code, codeSystem, codedValues, codes, _i, _len;
  codedValues = [];
  for (codeSystem in jsonCodes) {
    codes = jsonCodes[codeSystem];
    for (_i = 0, _len = codes.length; _i < _len; _i++) {
      code = codes[_i];
      codedValues.push(new hQuery.CodedValue(code, codeSystem));
    }
  }
  return codedValues;
};
/**
@namespace scoping into the hquery namespace
*/

var __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

this.hQuery || (this.hQuery = {});

/**
@class MedicationInformation
@exports MedicationInformation as hQuery.MedicationInformation
*/


hQuery.MedicationInformation = (function() {

  function MedicationInformation(json) {
    this.json = json;
  }

  /**
  An array of hQuery.CodedValue describing the medication
  @returns {Array}
  */


  MedicationInformation.prototype.codedProduct = function() {
    return hQuery.createCodedValues(this.json['codes']);
  };

  MedicationInformation.prototype.freeTextProductName = function() {
    return this.json['description'];
  };

  MedicationInformation.prototype.codedBrandName = function() {
    return this.json['codedBrandName'];
  };

  MedicationInformation.prototype.freeTextBrandName = function() {
    return this.json['brandName'];
  };

  MedicationInformation.prototype.drugManufacturer = function() {
    if (this.json['drugManufacturer']) {
      return new hQuery.Organization(this.json['drugManufacturer']);
    }
  };

  return MedicationInformation;

})();

/**
@class AdministrationTiming - the
@exports AdministrationTiming as hQuery.AdministrationTiming
*/


hQuery.AdministrationTiming = (function() {

  function AdministrationTiming(json) {
    this.json = json;
  }

  /**
  Provides the period of medication administration as a Scalar. An example
  Scalar that would be returned would be with value = 8 and units = hours. This would
  mean that the medication should be taken every 8 hours.
  @returns {hQuery.Scalar}
  */


  AdministrationTiming.prototype.period = function() {
    return new hQuery.Scalar(this.json['period']);
  };

  /**
  Indicates whether it is the interval (time between dosing), or frequency 
  (number of doses in a time period) that is important. If instititutionSpecified is not 
  present or is set to false, then the time between dosing is important (every 8 hours). 
  If true, then the frequency of administration is important (e.g., 3 times per day).
  @returns {Boolean}
  */


  AdministrationTiming.prototype.institutionSpecified = function() {
    return this.json['institutionSpecified'];
  };

  return AdministrationTiming;

})();

/**
@class DoseRestriction -  restrictions on the medications dose, represented by a upper and lower dose
@exports DoseRestriction as hQuery.DoseRestriction
*/


hQuery.DoseRestriction = (function() {

  function DoseRestriction(json) {
    this.json = json;
  }

  DoseRestriction.prototype.numerator = function() {
    return new hQuery.Scalar(this.json['numerator']);
  };

  DoseRestriction.prototype.denominator = function() {
    return new hQuery.Scalar(this.json['denominator']);
  };

  return DoseRestriction;

})();

/**
@class Fulfillment - information about when and who fulfilled an order for the medication
@exports Fulfillment as hQuery.Fullfilement
*/


hQuery.Fulfillment = (function() {

  function Fulfillment(json) {
    this.json = json;
  }

  Fulfillment.prototype.dispenseDate = function() {
    return hQuery.dateFromUtcSeconds(this.json['dispenseDate']);
  };

  Fulfillment.prototype.dispensingPharmacyLocation = function() {
    return new hQuery.Address(this.json['dispensingPharmacyLocation']);
  };

  Fulfillment.prototype.quantityDispensed = function() {
    return new hQuery.Scalar(this.json['quantityDispensed']);
  };

  Fulfillment.prototype.prescriptionNumber = function() {
    return this.json['prescriptionNumber'];
  };

  Fulfillment.prototype.fillNumber = function() {
    return this.json['fillNumber'];
  };

  Fulfillment.prototype.fillStatus = function() {
    return new hQuery.Status(this.json['fillStatus']);
  };

  return Fulfillment;

})();

/**
@class OrderInformation - information abour an order for a medication
@exports OrderInformation as hQuery.OrderInformation
*/


hQuery.OrderInformation = (function() {

  function OrderInformation(json) {
    this.json = json;
  }

  OrderInformation.prototype.orderNumber = function() {
    return this.json['orderNumber'];
  };

  OrderInformation.prototype.fills = function() {
    return this.json['fills'];
  };

  OrderInformation.prototype.quantityOrdered = function() {
    return new hQuery.Scalar(this.json['quantityOrdered']);
  };

  OrderInformation.prototype.orderExpirationDateTime = function() {
    return hQuery.dateFromUtcSeconds(this.json['orderExpirationDateTime']);
  };

  OrderInformation.prototype.orderDateTime = function() {
    return hQuery.dateFromUtcSeconds(this.json['orderDateTime']);
  };

  return OrderInformation;

})();

/**
TypeOfMedication as defined by value set 2.16.840.1.113883.3.88.12.3221.8.19
which pulls two values from SNOMED to describe whether a medication is
prescription or over the counter

@class TypeOfMedication - describes whether a medication is prescription or
       over the counter
@augments hQuery.CodedEntry
@exports TypeOfMedication as hQuery.TypeOfMedication
*/


hQuery.TypeOfMedication = (function(_super) {
  var OTC, PRESECRIPTION;

  __extends(TypeOfMedication, _super);

  function TypeOfMedication() {
    return TypeOfMedication.__super__.constructor.apply(this, arguments);
  }

  PRESECRIPTION = "73639000";

  OTC = "329505003";

  /**
  @returns {Boolean}
  */


  TypeOfMedication.prototype.isPrescription = function() {
    return this.c === PRESECRIPTION;
  };

  /**
  @returns {Boolean}
  */


  TypeOfMedication.prototype.isOverTheCounter = function() {
    return this.c === OTC;
  };

  return TypeOfMedication;

})(hQuery.CodedValue);

/**
StatusOfMedication as defined by value set 2.16.840.1.113883.1.11.20.7
The terms come from SNOMED and are managed by HL7

@class StatusOfMedication - describes the status of the medication
@augments hQuery.CodedEntry
@exports StatusOfMedication as hQuery.StatusOfMedication
*/


hQuery.StatusOfMedication = (function(_super) {
  var ACTIVE, NO_LONGER_ACTIVE, ON_HOLD, PRIOR_HISTORY;

  __extends(StatusOfMedication, _super);

  function StatusOfMedication() {
    return StatusOfMedication.__super__.constructor.apply(this, arguments);
  }

  ON_HOLD = "392521001";

  NO_LONGER_ACTIVE = "421139008";

  ACTIVE = "55561003";

  PRIOR_HISTORY = "73425007";

  /**
  @returns {Boolean}
  */


  StatusOfMedication.prototype.isOnHold = function() {
    return this.c === ON_HOLD;
  };

  /**
  @returns {Boolean}
  */


  StatusOfMedication.prototype.isNoLongerActive = function() {
    return this.c === NO_LONGER_ACTIVE;
  };

  /**
  @returns {Boolean}
  */


  StatusOfMedication.prototype.isActive = function() {
    return this.c === ACTIVE;
  };

  /**
  @returns {Boolean}
  */


  StatusOfMedication.prototype.isPriorHistory = function() {
    return this.c === PRIOR_HISTORY;
  };

  return StatusOfMedication;

})(hQuery.CodedValue);

/**
@class represents a medication entry for a patient.
@augments hQuery.CodedEntry
@exports Medication as hQuery.Medication
*/


hQuery.Medication = (function(_super) {

  __extends(Medication, _super);

  function Medication(json) {
    this.json = json;
    Medication.__super__.constructor.call(this, this.json);
  }

  /**
  @returns {String}
  */


  Medication.prototype.freeTextSig = function() {
    return this.json['freeTextSig'];
  };

  /**
  The actual or intended start of a medication. Slight deviation from greenCDA for C32 since
  it combines this with medication stop
  @returns {Date}
  */


  Medication.prototype.indicateMedicationStart = function() {
    return hQuery.dateFromUtcSeconds(this.json['start_time']);
  };

  /**
  The actual or intended stop of a medication. Slight deviation from greenCDA for C32 since
  it combines this with medication start
  @returns {Date}
  */


  Medication.prototype.indicateMedicationStop = function() {
    return hQuery.dateFromUtcSeconds(this.json['end_time']);
  };

  Medication.prototype.administrationTiming = function() {
    return new hQuery.AdministrationTiming(this.json['administrationTiming']);
  };

  /**
  @returns {CodedValue}  Contains routeCode or adminstrationUnitCode information.
    Route code shall have a a value drawn from FDA route of adminstration,
    and indicates how the medication is received by the patient.
    See http://www.fda.gov/Drugs/DevelopmentApprovalProcess/UCM070829
    The administration unit code shall have a value drawn from the FDA
    dosage form, source NCI thesaurus and represents the physical form of the
    product as presented to the patient.
    See http://www.fda.gov/Drugs/InformationOnDrugs/ucm142454.htm
  */


  Medication.prototype.route = function() {
    return new hQuery.CodedValue(this.json['route']['code'], this.json['route']['codeSystem']);
  };

  /**
  @returns {hQuery.Scalar} the dose
  */


  Medication.prototype.dose = function() {
    return new hQuery.Scalar(this.json['dose']);
  };

  /**
  @returns {CodedValue}
  */


  Medication.prototype.site = function() {
    return new hQuery.CodedValue(this.json['site']['code'], this.json['site']['codeSystem']);
  };

  /**
  @returns {hQuery.DoseRestriction}
  */


  Medication.prototype.doseRestriction = function() {
    return new hQuery.DoseRestriction(this.json['doseRestriction']);
  };

  /**
  @returns {String}
  */


  Medication.prototype.doseIndicator = function() {
    return this.json['doseIndicator'];
  };

  /**
  @returns {String}
  */


  Medication.prototype.fulfillmentInstructions = function() {
    return this.json['fulfillmentInstructions'];
  };

  /**
  @returns {CodedValue}
  */


  Medication.prototype.indication = function() {
    return new hQuery.CodedValue(this.json['indication']['code'], this.json['indication']['codeSystem']);
  };

  /**
  @returns {CodedValue}
  */


  Medication.prototype.productForm = function() {
    return new hQuery.CodedValue(this.json['productForm']['code'], this.json['productForm']['codeSystem']);
  };

  /**
  @returns {CodedValue}
  */


  Medication.prototype.vehicle = function() {
    return new hQuery.CodedValue(this.json['vehicle']['code'], this.json['vehicle']['codeSystem']);
  };

  /**
  @returns {CodedValue}
  */


  Medication.prototype.reaction = function() {
    return new hQuery.CodedValue(this.json['reaction']['code'], this.json['reaction']['codeSystem']);
  };

  /**
  @returns {CodedValue}
  */


  Medication.prototype.deliveryMethod = function() {
    return new hQuery.CodedValue(this.json['deliveryMethod']['code'], this.json['deliveryMethod']['codeSystem']);
  };

  /**
  @returns {hQuery.MedicationInformation}
  */


  Medication.prototype.medicationInformation = function() {
    return new hQuery.MedicationInformation(this.json);
  };

  /**
  @returns {hQuery.TypeOfMedication} Indicates whether this is an over the counter or prescription medication
  */


  Medication.prototype.typeOfMedication = function() {
    return new hQuery.TypeOfMedication(this.json['typeOfMedication']['code'], this.json['typeOfMedication']['codeSystem']);
  };

  /**
  Values conform to value set 2.16.840.1.113883.1.11.20.7 - Medication Status
  Values may be: On Hold, No Longer Active, Active, Prior History
  @returns {hQuery.StatusOfMedication}   Used to indicate the status of the medication.
  */


  Medication.prototype.statusOfMedication = function() {
    return new hQuery.StatusOfMedication(this.json['statusOfMedication']['code'], this.json['statusOfMedication']['codeSystem']);
  };

  /**
  @returns {String} free text instructions to the patient
  */


  Medication.prototype.patientInstructions = function() {
    return this.json['patientInstructions'];
  };

  /**
  The duration over which this medication has been active. For example, 5 days.
  @returns {Hash} with two keys: unit and scalar
  */


  Medication.prototype.cumulativeMedicationDuration = function() {
    return this.json['cumulativeMedicationDuration'];
  };

  /**
  @returns {Array} an array of {@link FulFillment} objects
  */


  Medication.prototype.fulfillmentHistory = function() {
    var order, _i, _len, _ref, _results;
    _ref = this.json['fulfillmentHistory'];
    _results = [];
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      order = _ref[_i];
      _results.push(new hQuery.Fulfillment(order));
    }
    return _results;
  };

  /**
  @returns {Array} an array of {@link OrderInformation} objects
  */


  Medication.prototype.orderInformation = function() {
    var order, _i, _len, _ref, _results;
    _ref = this.json['orderInformation'];
    _results = [];
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      order = _ref[_i];
      _results.push(new hQuery.OrderInformation(order));
    }
    return _results;
  };

  return Medication;

})(hQuery.CodedEntry);
/**
@namespace scoping into the hquery namespace
*/

var __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

this.hQuery || (this.hQuery = {});

/**
@class CauseOfDeath
@exports CauseOfDeath as hQuery.CauseOfDeath
*/


hQuery.CauseOfDeath = (function() {

  function CauseOfDeath(json) {
    this.json = json;
  }

  /**
  @returns {hQuery.Date}
  */


  CauseOfDeath.prototype.timeOfDeath = function() {
    return new hQuery.dateFromUtcSeconds(this.json['timeOfDeath']);
  };

  /**
  @returns {int}
  */


  CauseOfDeath.prototype.ageAtDeath = function() {
    return this.json['ageAtDeath'];
  };

  return CauseOfDeath;

})();

/**
@class hQuery.Condition

This section is used to describe a patients problems/conditions. The types of conditions
described have been constrained to the SNOMED CT Problem Type code set. An unbounded
number of treating providers for the particular condition can be supplied.
@exports Condition as hQuery.Condition 
@augments hQuery.CodedEntry
*/


hQuery.Condition = (function(_super) {

  __extends(Condition, _super);

  function Condition(json) {
    this.json = json;
    Condition.__super__.constructor.call(this, this.json);
  }

  /**
   @returns {Array, hQuery.Provider} an array of providers for the condition
  */


  Condition.prototype.providers = function() {
    var provider, _i, _len, _ref, _results;
    _ref = this.json['treatingProviders'];
    _results = [];
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      provider = _ref[_i];
      _results.push(new Provider(provider));
    }
    return _results;
  };

  /**
  Diagnosis Priority
  @returns {int}
  */


  Condition.prototype.diagnosisPriority = function() {
    return this.json['priority'];
  };

  /**
  Ordinality
  @returns {String}
  */


  Condition.prototype.ordinality = function() {
    return this.json['ordinality'];
  };

  /**
  age at onset
  @returns {int}
  */


  Condition.prototype.ageAtOnset = function() {
    return this.json['ageAtOnset'];
  };

  /**
  cause of death
  @returns {hQuery.CauseOfDeath}
  */


  Condition.prototype.causeOfDeath = function() {
    return new hQuery.CauseOfDeath(this.json['causeOfDeath']);
  };

  /**
  problem status
  @returns {hQuery.CodedValue}
  */


  Condition.prototype.problemStatus = function() {
    return new hQuery.CodedValue(this.json['problemStatus']['code'], this.json['problemStatus']['codeSystem']);
  };

  /**
  comment
  @returns {String}
  */


  Condition.prototype.comment = function() {
    return this.json['comment'];
  };

  /**
  This is a description of the level of the severity of the condition.
  @returns {CodedValue}
  */


  Condition.prototype.severity = function() {
    return new hQuery.CodedValue(this.json['severity']['code'], this.json['severity']['codeSystem']);
  };

  return Condition;

})(hQuery.CodedEntry);
/**
@namespace scoping into the hquery namespace
*/

var __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

this.hQuery || (this.hQuery = {});

/**
An Encounter is an interaction, regardless of the setting, between a patient and a
practitioner who is vested with primary responsibility for diagnosing, evaluating,
or treating the patient's condition. It may include visits, appointments, as well
as non face-to-face interactions. It is also a contact between a patient and a
practitioner who has primary responsibility for assessing and treating the
patient at a given contact, exercising independent judgment.
@class An Encounter is an interaction, regardless of the setting, between a patient and a
practitioner 
@augments hQuery.CodedEntry
@exports Encounter as hQuery.Encounter
*/


hQuery.Encounter = (function(_super) {

  __extends(Encounter, _super);

  function Encounter(json) {
    this.json = json;
    Encounter.__super__.constructor.call(this, this.json);
  }

  /**
  @returns {String}
  */


  Encounter.prototype.dischargeDisp = function() {
    return this.json['dischargeDisp'];
  };

  /**
  A code indicating the priority of the admission (e.g., Emergency, Urgent, Elective, et cetera) from
  National Uniform Billing Committee (NUBC)
  @returns {CodedValue}
  */


  Encounter.prototype.admitType = function() {
    return new hQuery.CodedValue(this.json['admitType']['code'], this.json['admitType']['codeSystem']);
  };

  /**
  @returns {hQuery.Actor}
  */


  Encounter.prototype.performer = function() {
    return new hQuery.Actor(this.json['performer']);
  };

  /**
  @returns {hQuery.Organization}
  */


  Encounter.prototype.facility = function() {
    return new hQuery.Facility(this.json['facility']);
  };

  /**
  @returns {hQuery.DateRange}
  */


  Encounter.prototype.encounterDuration = function() {
    return new hQuery.DateRange(this.json);
  };

  /**
  @returns {hQuery.CodedEntry}
  */


  Encounter.prototype.reasonForVisit = function() {
    return new hQuery.CodedEntry(this.json['reason']);
  };

  return Encounter;

})(hQuery.CodedEntry);
/**
@namespace scoping into the hquery namespace
*/

var __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

this.hQuery || (this.hQuery = {});

/**
This represents all interventional, surgical, diagnostic, or therapeutic procedures or 
treatments pertinent to the patient.
@class
@augments hQuery.CodedEntry
@exports Procedure as hQuery.Procedure
*/


hQuery.Procedure = (function(_super) {

  __extends(Procedure, _super);

  function Procedure(json) {
    this.json = json;
    Procedure.__super__.constructor.call(this, this.json);
  }

  /**
  @returns {hQuery.Actor} The provider that performed the procedure
  */


  Procedure.prototype.performer = function() {
    return new hQuery.Actor(this.json['performer']);
  };

  /**
  @returns {hQuery.CodedValue} A SNOMED code indicating the body site on which the 
  procedure was performed
  */


  Procedure.prototype.site = function() {
    return new hQuery.CodedValue(this.json['site']['code'], this.json['site']['codeSystem']);
  };

  return Procedure;

})(hQuery.CodedEntry);
/**
@namespace scoping into the hquery namespace
*/

var __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

this.hQuery || (this.hQuery = {});

/**
Observations generated by laboratories, imaging procedures, and other procedures. The scope
includes hematology, chemistry, serology, virology, toxicology, microbiology, plain x-ray,
ultrasound, CT, MRI, angiography, cardiac echo, nuclear medicine, pathology, and procedure
observations.
@class
@augments hQuery.CodedEntry
@exports Result as hQuery.Result
*/


hQuery.Result = (function(_super) {

  __extends(Result, _super);

  function Result(json) {
    this.json = json;
    Result.__super__.constructor.call(this, this.json);
  }

  /**
  ASTM CCR defines a restricted set of required result Type codes (see ResultTypeCode in section 7.3
  Summary of CCD value sets), used to categorize a result into one of several commonly accepted values
  (e.g. Hematology, Chemistry, Nuclear Medicine).
  @returns {CodedValue}
  */


  Result.prototype.resultType = function() {
    return this.type();
  };

  /**
  @returns {CodedValue}
  */


  Result.prototype.interpretation = function() {
    return new hQuery.CodedValue(this.json['interpretation'].code, this.json['interpretation'].codeSystem);
  };

  /**
  @returns {String}
  */


  Result.prototype.referenceRange = function() {
    return this.json['referenceRange'];
  };

  /**
  @returns {String}
  */


  Result.prototype.comment = function() {
    return this.json['comment'];
  };

  return Result;

})(hQuery.CodedEntry);
/**
@namespace scoping into the hquery namespace
*/

var __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

this.hQuery || (this.hQuery = {});

/**
NoImmunzation as defined by value set 2.16.840.1.113883.1.11.19717
The terms come from Health Level Seven (HL7) Version 3.0 Vocabulary and are managed by HL7
It indicates the reason an immunization was not administered.

@class NoImmunization - describes the status of the medication
@augments hQuery.CodedEntry
@exports NoImmunization as hQuery.NoImmunization
*/


hQuery.NoImmunization = (function(_super) {
  var IMMUNITY, MED_PRECAUTION, OUT_OF_STOCK, PAT_OBJ, PHIL_OBJ, REL_OBJ, VAC_EFF, VAC_SAFETY;

  __extends(NoImmunization, _super);

  function NoImmunization() {
    return NoImmunization.__super__.constructor.apply(this, arguments);
  }

  IMMUNITY = "IMMUNE";

  MED_PRECAUTION = "MEDPREC";

  OUT_OF_STOCK = "OSTOCK";

  PAT_OBJ = "PATOBJ";

  PHIL_OBJ = "PHILISOP";

  REL_OBJ = "RELIG";

  VAC_EFF = "VACEFF";

  VAC_SAFETY = "VACSAF";

  /**
  @returns {Boolean}
  */


  NoImmunization.prototype.isImmune = function() {
    return this.c === IMMUNITY;
  };

  /**
  @returns {Boolean}
  */


  NoImmunization.prototype.isMedPrec = function() {
    return this.c === MED_PRECAUTION;
  };

  /**
  @returns {Boolean}
  */


  NoImmunization.prototype.isOstock = function() {
    return this.c === OUT_OF_STOCK;
  };

  /**
  @returns {Boolean}
  */


  NoImmunization.prototype.isPatObj = function() {
    return this.c === PAT_OBJ;
  };

  /**
  @returns {Boolean}
  */


  NoImmunization.prototype.isPhilisop = function() {
    return this.c === PHIL_OBJ;
  };

  /**
  @returns {Boolean}
  */


  NoImmunization.prototype.isRelig = function() {
    return this.c === REL_OBJ;
  };

  /**
  @returns {Boolean}
  */


  NoImmunization.prototype.isVacEff = function() {
    return this.c === VAC_EFF;
  };

  /**
  @returns {Boolean}
  */


  NoImmunization.prototype.isVacSaf = function() {
    return this.c === VAC_SAFETY;
  };

  return NoImmunization;

})(hQuery.CodedValue);

/**
@class represents a immunization entry for a patient.
@augments hQuery.CodedEntry
@exports Immunization as hQuery.Immunization
*/


hQuery.Immunization = (function(_super) {

  __extends(Immunization, _super);

  function Immunization(json) {
    this.json = json;
    Immunization.__super__.constructor.call(this, this.json);
  }

  /**
  @returns{hQuery.Scalar}
  */


  Immunization.prototype.medicationSeriesNumber = function() {
    return new hQuery.Scalar(this.json['medicationSeriesNumber']);
  };

  /**
  @returns{hQuery.MedicationInformation}
  */


  Immunization.prototype.medicationInformation = function() {
    return new hQuery.MedicationInformation(this.json);
  };

  /**
  @returns{Date} Date immunization was administered
  */


  Immunization.prototype.administeredDate = function() {
    return dateFromUtcSeconds(this.json['administeredDate']);
  };

  /**
  @returns{hQuery.Actor} Performer of immunization
  */


  Immunization.prototype.performer = function() {
    return new hQuery.Actor(this.json['performer']);
  };

  /**
  @returns {comment} human readable description of event
  */


  Immunization.prototype.comment = function() {
    return this.json['comment'];
  };

  /**
  @returns {Boolean} whether the immunization has been refused by the patient.
  */


  Immunization.prototype.refusalInd = function() {
    return this.json['negationInd'];
  };

  /**
  NoImmunzation as defined by value set 2.16.840.1.113883.1.11.19717
  The terms come from Health Level Seven (HL7) Version 3.0 Vocabulary and are managed by HL7
  It indicates the reason an immunization was not administered.
  @returns {hQuery.NoImmunization}   Used to indicate reason an immunization was not administered.
  */


  Immunization.prototype.refusalReason = function() {
    return new hQuery.NoImmunization(this.json['negationReason']['code'], this.json['negationReason']['codeSystem']);
  };

  return Immunization;

})(hQuery.CodedEntry);
/**
@namespace scoping into the hquery namespace
*/

var __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

this.hQuery || (this.hQuery = {});

/**
@class 
@augments hQuery.CodedEntry
@exports Allergy as hQuery.Allergy
*/


hQuery.Allergy = (function(_super) {

  __extends(Allergy, _super);

  function Allergy(json) {
    this.json = json;
    Allergy.__super__.constructor.call(this, this.json);
  }

  /**
  Food and substance allergies use the Unique Ingredient Identifier(UNII) from the FDA
  http://www.fda.gov/ForIndustry/DataStandards/StructuredProductLabeling/ucm162523.htm
  
  Allegies to a class of medication Shall contain a value descending from the NDF-RT concept types 
  of Mechanism of Action - N0000000223, Physiologic Effect - N0000009802 or 
  Chemical Structure - N0000000002. NUI will be used as the concept code. 
  For more information, please see the Web Site 
  http://www.cancer.gov/cancertopics/terminologyresources/page5
  
  Allergies to a specific medication shall use RxNorm for the values.  
  @returns {CodedValue}
  */


  Allergy.prototype.product = function() {
    return this.type();
  };

  /**
  Date of allergy or adverse event
  @returns{Date}
  */


  Allergy.prototype.adverseEventDate = function() {
    return dateFromUtcSeconds(this.json['adverseEventDate']);
  };

  /**
  Adverse event types SHALL be coded as specified in HITSP/C80 Section 2.2.3.4.2 Allergy/Adverse Event Type
  @returns {CodedValue}
  */


  Allergy.prototype.adverseEventType = function() {
    return new hQuery.CodedValue(this.json['type']['code'], this.json['type']['codeSystem']);
  };

  /**
  This indicates the reaction that may be caused by the product or agent.  
   It is defined by 2.16.840.1.113883.3.88.12.3221.6.2 and are SNOMED-CT codes.
  420134006   Propensity to adverse reactions (disorder)
  418038007   Propensity to adverse reactions to substance (disorder)
  419511003   Propensity to adverse reactions to drug (disorder)
  418471000   Propensity to adverse reactions to food (disorder)
  419199007  Allergy to substance (disorder)
  416098002  Drug allergy (disorder)
  414285001  Food allergy (disorder)
  59037007  Drug intolerance (disorder)
  235719002  Food intolerance (disorder)
  @returns {CodedValue}
  */


  Allergy.prototype.reaction = function() {
    return new hQuery.CodedValue(this.json['reaction']['code'], this.json['reaction']['codeSystem']);
  };

  /**
  This is a description of the level of the severity of the allergy or intolerance.
  Use SNOMED-CT Codes as defined by 2.16.840.1.113883.3.88.12.3221.6.8
    255604002  Mild
    371923003  Mild to Moderate
    6736007      Moderate
    371924009  Moderate to Severe
    24484000    Severe
    399166001  Fatal
  @returns {CodedValue}
  */


  Allergy.prototype.severity = function() {
    return new hQuery.CodedValue(this.json['severity']['code'], this.json['severity']['codeSystem']);
  };

  /**
  Additional comment or textual information
  @returns {String}
  */


  Allergy.prototype.comment = function() {
    return this.json['comment'];
  };

  return Allergy;

})(hQuery.CodedEntry);
/**
@namespace scoping into the hquery namespace
*/

this.hQuery || (this.hQuery = {});

/**
@class 

@exports Provider as hQuery.Provider
*/


hQuery.Provider = (function() {

  function Provider(json) {
    this.json = json;
  }

  /**
  @returns {hQuery.Person}
  */


  Provider.prototype.providerEntity = function() {
    return new hQuery.Person(this.json['providerEntity']);
  };

  /**
  @returns {hQuery.DateRange}
  */


  Provider.prototype.careProvisionDateRange = function() {
    return new hQuery.DateRange(this.json['careProvisionDateRange']);
  };

  /**
  @returns {hQuery.CodedValue}
  */


  Provider.prototype.role = function() {
    return new hQuery.CodedValue(this.json['role']['code'], this.json['role']['codeSystem']);
  };

  /**
  @returns {String}
  */


  Provider.prototype.patientID = function() {
    return this.json['patientID'];
  };

  /**
  @returns {hQuery.CodedValue}
  */


  Provider.prototype.providerType = function() {
    return new hQuery.CodedValue(this.json['providerType']['code'], this.json['providerType']['codeSystem']);
  };

  /**
  @returns {String}
  */


  Provider.prototype.providerID = function() {
    return this.json['providerID'];
  };

  /**
  @returns {hQuery.Organization}
  */


  Provider.prototype.organizationName = function() {
    return new hQuery.Organization(this.json);
  };

  return Provider;

})();
/**
@namespace scoping into the hquery namespace
*/

var __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

this.hQuery || (this.hQuery = {});

/**
@class 
@augments hQuery.CodedEntry
@exports Language as hQuery.Language
*/


hQuery.Language = (function(_super) {

  __extends(Language, _super);

  function Language(json) {
    this.json = json;
    Language.__super__.constructor.call(this, this.json);
  }

  /**
  @returns {hQuery.CodedValue}
  */


  Language.prototype.modeCode = function() {
    return new hQuery.CodedValue(this.json['modeCode']['code'], this.json['modeCode']['codeSystem']);
  };

  /**
  @returns {String}
  */


  Language.prototype.preferenceIndicator = function() {
    return this.json['preferenceIndicator'];
  };

  return Language;

})(hQuery.CodedEntry);
/**
@namespace scoping into the hquery namespace
*/

var __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

this.hQuery || (this.hQuery = {});

/**
This includes information about the patients current and past pregnancy status
The Coded Entry code system should be SNOMED-CT
@class
@augments hQuery.CodedEntry
@exports Pregnancy as hQuery.Pregnancy
*/


hQuery.Pregnancy = (function(_super) {

  __extends(Pregnancy, _super);

  function Pregnancy(json) {
    this.json = json;
    Pregnancy.__super__.constructor.call(this, this.json);
  }

  /**
  @returns {String}
  */


  Pregnancy.prototype.comment = function() {
    return this.json['comment'];
  };

  return Pregnancy;

})(hQuery.CodedEntry);
/**
@namespace scoping into the hquery namespace
*/

var __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

this.hQuery || (this.hQuery = {});

/**

The Social History Observation is used to define the patient's occupational, personal (e.g. lifestyle), 
social, and environmental history and health risk factors, as well as administrative data such as 
marital status, race, ethnicity and religious affiliation. The types of conditions
described have been constrained to the SNOMED CT code system using constrained code set, 2.16.840.1.113883.3.88.12.80.60:
229819007   Tobacco use and exposure
256235009   Exercise
160573003   Alcohol Intake
364393001   Nutritional observable
364703007   Employment detail
425400000   Toxic exposure status
363908000   Details of drug misuse behavior
228272008   Health-related behavior
105421008   Educational achievement

note:  Social History is not part of the existing green c32.
@exports Socialhistory as hQuery.Socialhistory 
@augments hQuery.CodedEntry
*/


hQuery.Socialhistory = (function(_super) {

  __extends(Socialhistory, _super);

  function Socialhistory(json) {
    this.json = json;
    Socialhistory.__super__.constructor.call(this, this.json);
  }

  /**
  Value returns the value of the result. This will return an object. The properties of this
  object are dependent on the type of result.
  */


  Socialhistory.prototype.value = function() {
    return this.json['value'];
  };

  return Socialhistory;

})(hQuery.CodedEntry);
/**
@namespace scoping into the hquery namespace
*/

var __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

this.hQuery || (this.hQuery = {});

/**

The plan of care contains data defining prospective or intended orders, interventions, encounters, services, and procedures for the patient.

@exports CareGoal as hQuery.CareGoal 
@augments hQuery.CodedEntry
*/


hQuery.CareGoal = (function(_super) {

  __extends(CareGoal, _super);

  function CareGoal(json) {
    this.json = json;
    CareGoal.__super__.constructor.call(this, this.json);
  }

  return CareGoal;

})(hQuery.CodedEntry);
/**
@namespace scoping into the hquery namespace
*/

var __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

this.hQuery || (this.hQuery = {});

/**

The Medical Equipment section contains information describing a patients implanted and external medical devices and equipment that their health status depends on, as well as any pertinent equipment or device history.

The template identifier for this section is 2.16.840.1.113883.3.88.11.83.128

C83-[CT-128-1] This section shall conform to the HL7 CCD section, and shall contain a templateId element whose root attribute is 2.16.840.1.113883.10.20.1.7.
C83-[CT-128-2] This section SHALL conform to the IHE Medical Devices Section, and shall contain a templateId element whose root attribute is 1.3.6.1.4.1.19376.1.5.3.1.1.5.3.5

@exports MedicalEquipment as hQuery.MedicalEquipment 
@augments hQuery.CodedEntry
*/


hQuery.MedicalEquipment = (function(_super) {

  __extends(MedicalEquipment, _super);

  function MedicalEquipment(json) {
    this.json = json;
    MedicalEquipment.__super__.constructor.call(this, this.json);
  }

  return MedicalEquipment;

})(hQuery.CodedEntry);
/**
@namespace scoping into the hquery namespace
*/

var __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

this.hQuery || (this.hQuery = {});

/**
This class can be used to represnt a functional status for a patient. Currently,
it is not a very close representation of functional status as it is represented
in the HL7 CCD, HITSP C32 or Consolidated CDA.

In the previously mentioned specifications, functional status may represented
using either a condition or result. Having "mixed" types of entries in a section
is currently not well supported in the existing Record class

Additionally, there is a mismatch between the data needed to calculate Stage 2
Meaningful Use Quailty Measures and the data contained in patient summary
standards. The CQMs are checking to see if a functional status represented by
a result was patient supplied. Right now, results do not have a source, and
even if we were to use Provider as a source, it would need to be extended
to support patients.

To avoid this, the patient sumamry style functional status has been "flattened"
into this class. This model supports the information needed to calculate
Stage 2 MU CQMs. If importers are created from C32 or CCDA, the information
can be stored here, but it will be a lossy transformation.
@class
@augments hQuery.CodedEntry
@exports FunctionalStatus as hQuery.FunctionalStatus
*/


hQuery.FunctionalStatus = (function(_super) {

  __extends(FunctionalStatus, _super);

  function FunctionalStatus(json) {
    this.json = json;
    FunctionalStatus.__super__.constructor.call(this, this.json);
  }

  /**
  Either "condition" or "result"
  @returns {String}
  */


  FunctionalStatus.prototype.type = function() {
    return this.json["type"];
  };

  /**
  A coded value. Like a code for patient supplied.
  @returns {hQuery.CodedValue}
  */


  FunctionalStatus.prototype.source = function() {
    if (this.json["source"] != null) {
      return new hQuery.CodedValue(this.json["source"]["code"], this.json["source"]["codeSystem"]);
    }
  };

  return FunctionalStatus;

})(hQuery.CodedEntry);
/**
@namespace scoping into the hquery namespace
*/

var __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

this.hQuery || (this.hQuery = {});

/**
@class Supports
@exports Supports as hQuery.Supports
*/


hQuery.Supports = (function() {

  function Supports(json) {
    this.json = json;
  }

  /**
  @returns {DateRange}
  */


  Supports.prototype.supportDate = function() {
    return new hQuery.DateRange(this.json['supportDate']);
  };

  /**
  @returns {Person}
  */


  Supports.prototype.guardian = function() {
    return new hQuery.Person(this.json['guardian']);
  };

  /**
  @returns {String}
  */


  Supports.prototype.guardianSupportType = function() {
    return this.json['guardianSupportType'];
  };

  /**
  @returns {Person}
  */


  Supports.prototype.contact = function() {
    return new hQuery.Person(this.json['contact']);
  };

  /**
  @returns {String}
  */


  Supports.prototype.contactSupportType = function() {
    return this.json['guardianSupportType'];
  };

  return Supports;

})();

/**
@class Representation of a patient
@augments hQuery.Person
@exports Patient as hQuery.Patient
*/


hQuery.Patient = (function(_super) {

  __extends(Patient, _super);

  function Patient() {
    return Patient.__super__.constructor.apply(this, arguments);
  }

  /**
  @returns {String} containing M or F representing the gender of the patient
  */


  Patient.prototype.gender = function() {
    return this.json['gender'];
  };

  /**
  @returns {Date} containing the patient's birthdate
  */


  Patient.prototype.birthtime = function() {
    return hQuery.dateFromUtcSeconds(this.json['birthdate']);
  };

  /**
  @param (Date) date the date at which the patient age is calculated, defaults to now.
  @returns {number} the patient age in years
  */


  Patient.prototype.age = function(date) {
    var oneDay, oneYear;
    if (date == null) {
      date = new Date();
    }
    oneDay = 24 * 60 * 60 * 1000;
    oneYear = 365 * oneDay;
    return (date.getTime() - this.birthtime().getTime()) / oneYear;
  };

  /**
  @returns {CodedValue} the domestic partnership status of the patient
  The following HL7 codeset is used:
  A  Annulled
  D  Divorced
  I   Interlocutory
  L  Legally separated
  M  Married
  P  Polygamous
  S  Never Married
  T  Domestic Partner
  W  Widowed
  */


  Patient.prototype.maritalStatus = function() {
    if (this.json['maritalStatus']) {
      return new hQuery.CodedValue(this.json['maritalStatus']['code'], this.json['maritalStatus']['codeSystem']);
    }
  };

  /**
  @returns {CodedValue}  of the spiritual faith affiliation of the patient
  It uses the HL7 codeset.  http://www.hl7.org/memonly/downloads/v3edition.cfm#V32008
  */


  Patient.prototype.religiousAffiliation = function() {
    if (this.json['religiousAffiliation']) {
      return new hQuery.CodedValue(this.json['religiousAffiliation']['code'], this.json['religiousAffiliation']['codeSystem']);
    }
  };

  /**
  @returns {CodedValue}  of the race of the patient
  CDC codes:  http://phinvads.cdc.gov/vads/ViewCodeSystemConcept.action?oid=2.16.840.1.113883.6.238&code=1000-9
  */


  Patient.prototype.race = function() {
    if (this.json['race']) {
      return new hQuery.CodedValue(this.json['race']['code'], this.json['race']['codeSystem']);
    }
  };

  /**
  @returns {CodedValue} of the ethnicity of the patient
  CDC codes:  http://phinvads.cdc.gov/vads/ViewCodeSystemConcept.action?oid=2.16.840.1.113883.6.238&code=1000-9
  */


  Patient.prototype.ethnicity = function() {
    if (this.json['ethnicity']) {
      return new hQuery.CodedValue(this.json['ethnicity']['code'], this.json['ethnicity']['codeSystem']);
    }
  };

  /**
  @returns {CodedValue} This is the code specifying the level of confidentiality of the document.
  HL7 Confidentiality Code (2.16.840.1.113883.5.25)
  */


  Patient.prototype.confidentiality = function() {
    if (this.json['confidentiality']) {
      return new hQuery.CodedValue(this.json['confidentiality']['code'], this.json['confidentiality']['codeSystem']);
    }
  };

  /**
  @returns {Address} of the location where the patient was born
  */


  Patient.prototype.birthPlace = function() {
    return new hQuery.Address(this.json['birthPlace']);
  };

  /**
  @returns {Supports} information regarding key support contacts relative to healthcare decisions, including next of kin
  */


  Patient.prototype.supports = function() {
    return new hQuery.Supports(this.json['supports']);
  };

  /**
  @returns {Organization}
  */


  Patient.prototype.custodian = function() {
    return new hQuery.Organization(this.json['custodian']);
  };

  /**
  @returns {Provider}  the providers associated with the patient
  */


  Patient.prototype.provider = function() {
    return new hQuery.Provider(this.json['provider']);
  };

  /**
  @returns {hQuery.CodedEntryList} A list of {@link hQuery.LanguagesSpoken} objects
  Code from http://www.ietf.org/rfc/rfc4646.txt representing the name of the human language
  */


  Patient.prototype.languages = function() {
    var language, list, _i, _len, _ref;
    list = new hQuery.CodedEntryList;
    if (this.json['languages']) {
      _ref = this.json['languages'];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        language = _ref[_i];
        list.push(new hQuery.Language(language));
      }
    }
    return list;
  };

  /**
  @returns {Boolean} returns true if the patient has died
  */


  Patient.prototype.expired = function() {
    return this.json['expired'];
  };

  /**
  @returns {Boolean} returns true if the patient participated in a clinical trial
  */


  Patient.prototype.clinicalTrialParticipant = function() {
    return this.json['clinicalTrialParticipant'];
  };

  /**
  @returns {hQuery.CodedEntryList} A list of {@link hQuery.Encounter} objects
  */


  Patient.prototype.encounters = function() {
    var encounter, list, _i, _len, _ref;
    list = new hQuery.CodedEntryList;
    if (this.json['encounters']) {
      _ref = this.json['encounters'];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        encounter = _ref[_i];
        list.pushIfUsable(new hQuery.Encounter(encounter));
      }
    }
    return list;
  };

  /**
  @returns {hQuery.CodedEntryList} A list of {@link Medication} objects
  */


  Patient.prototype.medications = function() {
    var list, medication, _i, _len, _ref;
    list = new hQuery.CodedEntryList;
    if (this.json['medications']) {
      _ref = this.json['medications'];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        medication = _ref[_i];
        list.pushIfUsable(new hQuery.Medication(medication));
      }
    }
    return list;
  };

  /**
  @returns {hQuery.CodedEntryList} A list of {@link Condition} objects
  */


  Patient.prototype.conditions = function() {
    var condition, list, _i, _len, _ref;
    list = new hQuery.CodedEntryList;
    if (this.json['conditions']) {
      _ref = this.json['conditions'];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        condition = _ref[_i];
        list.pushIfUsable(new hQuery.Condition(condition));
      }
    }
    return list;
  };

  /**
  @returns {hQuery.CodedEntryList} A list of {@link Procedure} objects
  */


  Patient.prototype.procedures = function() {
    var list, procedure, _i, _len, _ref;
    list = new hQuery.CodedEntryList;
    if (this.json['procedures']) {
      _ref = this.json['procedures'];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        procedure = _ref[_i];
        list.pushIfUsable(new hQuery.Procedure(procedure));
      }
    }
    return list;
  };

  /**
  @returns {hQuery.CodedEntryList} A list of {@link Result} objects
  */


  Patient.prototype.results = function() {
    var list, result, _i, _len, _ref;
    list = new hQuery.CodedEntryList;
    if (this.json['results']) {
      _ref = this.json['results'];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        result = _ref[_i];
        list.pushIfUsable(new hQuery.Result(result));
      }
    }
    return list;
  };

  /**
  @returns {hQuery.CodedEntryList} A list of {@link Result} objects
  */


  Patient.prototype.vitalSigns = function() {
    var list, vital, _i, _len, _ref;
    list = new hQuery.CodedEntryList;
    if (this.json['vital_signs']) {
      _ref = this.json['vital_signs'];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        vital = _ref[_i];
        list.pushIfUsable(new hQuery.Result(vital));
      }
    }
    return list;
  };

  /**
  @returns {hQuery.CodedEntryList} A list of {@link Immunization} objects
  */


  Patient.prototype.immunizations = function() {
    var immunization, list, _i, _len, _ref;
    list = new hQuery.CodedEntryList;
    if (this.json['immunizations']) {
      _ref = this.json['immunizations'];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        immunization = _ref[_i];
        list.pushIfUsable(new hQuery.Immunization(immunization));
      }
    }
    return list;
  };

  /**
  @returns {hQuery.CodedEntryList} A list of {@link Allergy} objects
  */


  Patient.prototype.allergies = function() {
    var allergy, list, _i, _len, _ref;
    list = new hQuery.CodedEntryList;
    if (this.json['allergies']) {
      _ref = this.json['allergies'];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        allergy = _ref[_i];
        list.pushIfUsable(new hQuery.Allergy(allergy));
      }
    }
    return list;
  };

  /**
  @returns {hQuery.CodedEntryList} A list of {@link Pregnancy} objects
  */


  Patient.prototype.pregnancies = function() {
    var list, pregnancy, _i, _len, _ref;
    list = new hQuery.CodedEntryList;
    if (this.json['pregnancies']) {
      _ref = this.json['pregnancies'];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        pregnancy = _ref[_i];
        list.pushIfUsable(new hQuery.Pregnancy(pregnancy));
      }
    }
    return list;
  };

  /**
  @returns {hQuery.CodedEntryList} A list of {@link Socialhistory} objects
  */


  Patient.prototype.socialHistories = function() {
    var list, socialhistory, _i, _len, _ref;
    list = new hQuery.CodedEntryList;
    if (this.json['socialhistories']) {
      _ref = this.json['socialhistories'];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        socialhistory = _ref[_i];
        list.pushIfUsable(new hQuery.Socialhistory(socialhistory));
      }
    }
    return list;
  };

  /**
  @returns {hQuery.CodedEntryList} A list of {@link CareGoal} objects
  */


  Patient.prototype.careGoals = function() {
    var caregoal, list, _i, _len, _ref;
    list = new hQuery.CodedEntryList;
    if (this.json['care_goals']) {
      _ref = this.json['care_goals'];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        caregoal = _ref[_i];
        list.pushIfUsable(new hQuery.CareGoal(caregoal));
      }
    }
    return list;
  };

  /**
  @returns {hQuery.CodedEntryList} A list of {@link MedicalEquipment} objects
  */


  Patient.prototype.medicalEquipment = function() {
    var equipment, list, _i, _len, _ref;
    list = new hQuery.CodedEntryList;
    if (this.json['medical_equipment']) {
      _ref = this.json['medical_equipment'];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        equipment = _ref[_i];
        list.pushIfUsable(new hQuery.MedicalEquipment(equipment));
      }
    }
    return list;
  };

  /**
  @returns {hQuery.CodedEntryList} A list of {@link FunctionalStatus} objects
  */


  Patient.prototype.functionalStatuses = function() {
    var fs, list, _i, _len, _ref;
    list = new hQuery.CodedEntryList;
    if (this.json['functional_statuses']) {
      _ref = this.json['functional_statuses'];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        fs = _ref[_i];
        list.pushIfUsable(new hQuery.FunctionalStatus(fs));
      }
    }
    return list;
  };

  return Patient;

})(hQuery.Person);

// #########################
// ### LIBRARY FUNCTIONS ####
// #########################

var ANYNonNull, CD, CONCURRENT, COUNT, CodeList, CrossProduct, DURING, EAE, EAS, EBE, EBS, ECW, ECWS, EDU, FIFTH, FIRST, FOURTH, IVL_PQ, IVL_TS, LAST, MAX, MIN, OVERLAP, PQ, PREVSUM, RECENT, SAE, SAS, SBE, SBS, SCW, SCWE, SDU, SECOND, THIRD, TS, UNION, XPRODUCT, allFalse, allTrue, anyMatchingValue, applySpecificOccurrenceSubset, atLeastOneFalse, atLeastOneTrue, boundAccessor, dateSortAscending, dateSortDescending, eventAccessor, eventMatchesBounds, eventsMatchBounds, fieldOrContainerValue, filterEventsByField, filterEventsByValue, getCodes, getIVL, hqmfjs, matchingValue, valueSortAscending, valueSortDescending, withinRange,
  __slice = [].slice,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

TS = (function() {

  function TS(hl7ts, inclusive) {
    var day, hour, minute, month, year;
    this.inclusive = inclusive != null ? inclusive : false;
    if (hl7ts) {
      year = parseInt(hl7ts.substring(0, 4));
      month = parseInt(hl7ts.substring(4, 6), 10) - 1;
      day = parseInt(hl7ts.substring(6, 8), 10);
      hour = parseInt(hl7ts.substring(8, 10), 10);
      if (isNaN(hour)) {
        hour = 0;
      }
      minute = parseInt(hl7ts.substring(10, 12), 10);
      if (isNaN(minute)) {
        minute = 0;
      }
      this.date = new Date(year, month, day, hour, minute);
    } else {
      this.date = new Date();
    }
  }

  TS.prototype.add = function(pq) {
    if (pq.unit === "a") {
      this.date.setFullYear(this.date.getFullYear() + pq.value);
    } else if (pq.unit === "mo") {
      this.date.setMonth(this.date.getMonth() + pq.value);
    } else if (pq.unit === "wk") {
      this.date.setDate(this.date.getDate() + (7 * pq.value));
    } else if (pq.unit === "d") {
      this.date.setDate(this.date.getDate() + pq.value);
    } else if (pq.unit === "h") {
      this.date.setHours(this.date.getHours() + pq.value);
    } else if (pq.unit === "min") {
      this.date.setMinutes(this.date.getMinutes() + pq.value);
    } else {
      throw "Unknown time unit: " + pq.unit;
    }
    return this;
  };

  TS.prototype.difference = function(ts, granularity) {
    var earlier, later;
    earlier = later = null;
    if (this.afterOrConcurrent(ts)) {
      earlier = ts.asDate();
      later = this.date;
    } else {
      earlier = this.date;
      later = ts.asDate();
    }
    if (granularity === "a") {
      return TS.yearsDifference(earlier, later);
    } else if (granularity === "mo") {
      return TS.monthsDifference(earlier, later);
    } else if (granularity === "wk") {
      return TS.weeksDifference(earlier, later);
    } else if (granularity === "d") {
      return TS.daysDifference(earlier, later);
    } else if (granularity === "h") {
      return TS.hoursDifference(earlier, later);
    } else if (granularity === "min") {
      return TS.minutesDifference(earlier, later);
    } else {
      throw "Unknown time unit: " + granularity;
    }
  };

  TS.prototype.asDate = function() {
    return this.date;
  };

  TS.prototype.before = function(other) {
    var a, b, _ref;
    if (this.date === null || other.date === null) {
      return false;
    }
    if (other.inclusive) {
      return beforeOrConcurrent(other);
    } else {
      _ref = TS.dropSeconds(this.date, other.date), a = _ref[0], b = _ref[1];
      return a.getTime() < b.getTime();
    }
  };

  TS.prototype.after = function(other) {
    var a, b, _ref;
    if (this.date === null || other.date === null) {
      return false;
    }
    if (other.inclusive) {
      return afterOrConcurrent(other);
    } else {
      _ref = TS.dropSeconds(this.date, other.date), a = _ref[0], b = _ref[1];
      return a.getTime() > b.getTime();
    }
  };

  TS.prototype.beforeOrConcurrent = function(other) {
    var a, b, _ref;
    if (this.date === null || other.date === null) {
      return false;
    }
    _ref = TS.dropSeconds(this.date, other.date), a = _ref[0], b = _ref[1];
    return a.getTime() <= b.getTime();
  };

  TS.prototype.afterOrConcurrent = function(other) {
    var a, b, _ref;
    if (this.date === null || other.date === null) {
      return false;
    }
    _ref = TS.dropSeconds(this.date, other.date), a = _ref[0], b = _ref[1];
    return a.getTime() >= b.getTime();
  };

  TS.prototype.withinSameMinute = function(other) {
    var a, b, _ref;
    _ref = TS.dropSeconds(this.date, other.date), a = _ref[0], b = _ref[1];
    return a.getTime() === b.getTime();
  };

  TS.yearsDifference = function(earlier, later) {
    if (later.getMonth() < earlier.getMonth()) {
      return later.getFullYear() - earlier.getFullYear() - 1;
    } else if (later.getMonth() === earlier.getMonth() && later.getDate() >= earlier.getDate()) {
      return later.getFullYear() - earlier.getFullYear();
    } else if (later.getMonth() === earlier.getMonth() && later.getDate() < earlier.getDate()) {
      return later.getFullYear() - earlier.getFullYear() - 1;
    } else {
      return later.getFullYear() - earlier.getFullYear();
    }
  };

  TS.monthsDifference = function(earlier, later) {
    if (later.getDate() >= earlier.getDate()) {
      return (later.getFullYear() - earlier.getFullYear()) * 12 + later.getMonth() - earlier.getMonth();
    } else {
      return (later.getFullYear() - earlier.getFullYear()) * 12 + later.getMonth() - earlier.getMonth() - 1;
    }
  };

  TS.minutesDifference = function(earlier, later) {
    return Math.floor(((later.getTime() - earlier.getTime()) / 1000) / 60);
  };

  TS.hoursDifference = function(earlier, later) {
    return Math.floor(TS.minutesDifference(earlier, later) / 60);
  };

  TS.daysDifference = function(earlier, later) {
    var e, l;
    e = new Date(earlier.getFullYear(), earlier.getMonth(), earlier.getDate());
    e.setUTCHours(0);
    l = new Date(later.getFullYear(), later.getMonth(), later.getDate());
    l.setUTCHours(0);
    return Math.floor(TS.hoursDifference(e, l) / 24);
  };

  TS.weeksDifference = function(earlier, later) {
    return Math.floor(TS.daysDifference(earlier, later) / 7);
  };

  TS.dropSeconds = function() {
    var noSeconds, timeStamp, timeStamps, timeStampsNoSeconds;
    timeStamps = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
    timeStampsNoSeconds = (function() {
      var _i, _len, _results;
      _results = [];
      for (_i = 0, _len = timeStamps.length; _i < _len; _i++) {
        timeStamp = timeStamps[_i];
        noSeconds = new Date(timeStamp.getTime());
        noSeconds.setSeconds(0);
        _results.push(noSeconds);
      }
      return _results;
    })();
    return timeStampsNoSeconds;
  };

  return TS;

})();

this.TS = TS;

fieldOrContainerValue = function(value, fieldName, defaultToValue) {
  if (defaultToValue == null) {
    defaultToValue = true;
  }
  if (value != null) {
    if (typeof value[fieldName] === 'function') {
      return value[fieldName]();
    } else if (typeof value[fieldName] !== 'undefined') {
      return value[fieldName];
    } else if (defaultToValue) {
      return value;
    } else {
      return null;
    }
  } else {
    return null;
  }
};

this.fieldOrContainerValue = fieldOrContainerValue;

CD = (function() {

  function CD(code, system) {
    this.code = code;
    this.system = system;
  }

  CD.prototype.match = function(codeOrHash) {
    var codeToMatch, systemToMatch;
    codeToMatch = fieldOrContainerValue(codeOrHash, 'code');
    systemToMatch = fieldOrContainerValue(codeOrHash, 'codeSystemName', false);
    if (this.system && systemToMatch) {
      return this.code === codeToMatch && this.system === systemToMatch;
    } else {
      return this.code === codeToMatch;
    }
  };

  return CD;

})();

this.CD = CD;

CodeList = (function() {

  function CodeList(codes) {
    this.codes = codes;
  }

  CodeList.prototype.match = function(codeOrHash) {
    var code, codeList, codeSystemName, codeToMatch, result, systemToMatch, _i, _len, _ref;
    codeToMatch = fieldOrContainerValue(codeOrHash, 'code');
    systemToMatch = fieldOrContainerValue(codeOrHash, 'codeSystemName', false);
    result = false;
    _ref = this.codes;
    for (codeSystemName in _ref) {
      codeList = _ref[codeSystemName];
      for (_i = 0, _len = codeList.length; _i < _len; _i++) {
        code = codeList[_i];
        if (codeSystemName && systemToMatch) {
          if (code === codeToMatch && codeSystemName === systemToMatch) {
            result = true;
          }
        } else if (code === codeToMatch) {
          result = true;
        }
      }
    }
    return result;
  };

  return CodeList;

})();

this.CodeList = CodeList;

PQ = (function() {

  function PQ(value, unit, inclusive) {
    this.value = value;
    this.unit = unit;
    this.inclusive = inclusive != null ? inclusive : true;
  }

  PQ.prototype.lessThan = function(val) {
    if (this.inclusive) {
      return this.lessThanOrEqual(val);
    } else {
      return this.value < val;
    }
  };

  PQ.prototype.greaterThan = function(val) {
    if (this.inclusive) {
      return this.greaterThanOrEqual(val);
    } else {
      return this.value > val;
    }
  };

  PQ.prototype.lessThanOrEqual = function(val) {
    return this.value <= val;
  };

  PQ.prototype.greaterThanOrEqual = function(val) {
    return this.value >= val;
  };

  PQ.prototype.match = function(scalarOrHash) {
    var val;
    val = fieldOrContainerValue(scalarOrHash, 'scalar');
    return this.value === val;
  };

  return PQ;

})();

this.PQ = PQ;

IVL_PQ = (function() {

  function IVL_PQ(low_pq, high_pq) {
    this.low_pq = low_pq;
    this.high_pq = high_pq;
    if (!this.low_pq && !this.high_pq) {
      throw "Must have a lower or upper bound";
    }
    if (this.low_pq && this.low_pq.unit && this.high_pq && this.high_pq.unit && this.low_pq.unit !== this.high_pq.unit) {
      throw "Mismatched low and high units: " + this.low_pq.unit + ", " + this.high_pq.unit;
    }
  }

  IVL_PQ.prototype.unit = function() {
    if (this.low_pq) {
      return this.low_pq.unit;
    } else {
      return this.high_pq.unit;
    }
  };

  IVL_PQ.prototype.match = function(scalarOrHash) {
    var val;
    val = fieldOrContainerValue(scalarOrHash, 'scalar');
    return (!(this.low_pq != null) || this.low_pq.lessThan(val)) && (!(this.high_pq != null) || this.high_pq.greaterThan(val));
  };

  return IVL_PQ;

})();

this.IVL_PQ = IVL_PQ;

IVL_TS = (function() {

  function IVL_TS(low, high) {
    this.low = low;
    this.high = high;
  }

  IVL_TS.prototype.add = function(pq) {
    this.low.add(pq);
    this.high.add(pq);
    return this;
  };

  IVL_TS.prototype.DURING = function(other) {
    return this.SDU(other) && this.EDU(other);
  };

  IVL_TS.prototype.OVERLAP = function(other) {
    return this.SDU(other) || this.EDU(other) || (this.SBS(other) && this.EAE(other));
  };

  IVL_TS.prototype.SBS = function(other) {
    return this.low.before(other.low);
  };

  IVL_TS.prototype.SAS = function(other) {
    return this.low.after(other.low);
  };

  IVL_TS.prototype.SBE = function(other) {
    return this.low.before(other.high);
  };

  IVL_TS.prototype.SAE = function(other) {
    return this.low.after(other.high);
  };

  IVL_TS.prototype.EBS = function(other) {
    return this.high.before(other.low);
  };

  IVL_TS.prototype.EAS = function(other) {
    return this.high.after(other.low);
  };

  IVL_TS.prototype.EBE = function(other) {
    return this.high.before(other.high);
  };

  IVL_TS.prototype.EAE = function(other) {
    return this.high.after(other.high);
  };

  IVL_TS.prototype.SDU = function(other) {
    return this.low.afterOrConcurrent(other.low) && this.low.beforeOrConcurrent(other.high);
  };

  IVL_TS.prototype.EDU = function(other) {
    return this.high.afterOrConcurrent(other.low) && this.high.beforeOrConcurrent(other.high);
  };

  IVL_TS.prototype.ECW = function(other) {
    return this.high.asDate() && other.high.asDate() && this.high.withinSameMinute(other.high);
  };

  IVL_TS.prototype.SCW = function(other) {
    return this.low.asDate() && other.low.asDate() && this.low.withinSameMinute(other.low);
  };

  IVL_TS.prototype.ECWS = function(other) {
    return this.high.asDate() && other.low.asDate() && this.high.withinSameMinute(other.low);
  };

  IVL_TS.prototype.SCWE = function(other) {
    return this.low.asDate() && other.high.asDate() && this.low.withinSameMinute(other.high);
  };

  IVL_TS.prototype.CONCURRENT = function(other) {
    return this.SCW(other) && this.ECW(other);
  };

  return IVL_TS;

})();

this.IVL_TS = IVL_TS;

ANYNonNull = (function() {

  function ANYNonNull() {}

  ANYNonNull.prototype.match = function(scalarOrHash) {
    var val;
    val = fieldOrContainerValue(scalarOrHash, 'scalar');
    return val !== null;
  };

  return ANYNonNull;

})();

this.ANYNonNull = ANYNonNull;

atLeastOneTrue = function() {
  var trueValues, value, values;
  values = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
  trueValues = (function() {
    var _i, _len, _results;
    _results = [];
    for (_i = 0, _len = values.length; _i < _len; _i++) {
      value = values[_i];
      if (value && value.isTrue()) {
        _results.push(value);
      }
    }
    return _results;
  })();
  trueValues.length > 0;
  return Specifics.unionAll(new Boolean(trueValues.length > 0), values);
};

this.atLeastOneTrue = atLeastOneTrue;

allTrue = function() {
  var trueValues, value, values;
  values = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
  trueValues = (function() {
    var _i, _len, _results;
    _results = [];
    for (_i = 0, _len = values.length; _i < _len; _i++) {
      value = values[_i];
      if (value && value.isTrue()) {
        _results.push(value);
      }
    }
    return _results;
  })();
  return Specifics.intersectAll(new Boolean(trueValues.length > 0 && trueValues.length === values.length), values);
};

this.allTrue = allTrue;

atLeastOneFalse = function() {
  var falseValues, value, values;
  values = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
  falseValues = (function() {
    var _i, _len, _results;
    _results = [];
    for (_i = 0, _len = values.length; _i < _len; _i++) {
      value = values[_i];
      if (value.isFalse()) {
        _results.push(value);
      }
    }
    return _results;
  })();
  return Specifics.intersectAll(new Boolean(falseValues.length > 0), values, true);
};

this.atLeastOneFalse = atLeastOneFalse;

allFalse = function() {
  var falseValues, value, values;
  values = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
  falseValues = (function() {
    var _i, _len, _results;
    _results = [];
    for (_i = 0, _len = values.length; _i < _len; _i++) {
      value = values[_i];
      if (value.isFalse()) {
        _results.push(value);
      }
    }
    return _results;
  })();
  return Specifics.unionAll(new Boolean(falseValues.length > 0 && falseValues.length === values.length), values, true);
};

this.allFalse = allFalse;

matchingValue = function(value, compareTo) {
  return new Boolean(compareTo.match(value));
};

this.matchingValue = matchingValue;

anyMatchingValue = function(event, valueToMatch) {
  var matchingValues, value;
  matchingValues = (function() {
    var _i, _len, _ref, _results;
    _ref = event.values();
    _results = [];
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      value = _ref[_i];
      if (valueToMatch.match(value)) {
        _results.push(value);
      }
    }
    return _results;
  })();
  return matchingValues.length > 0;
};

this.anyMatchingValue = anyMatchingValue;

filterEventsByValue = function(events, value) {
  var event, matchingEvents;
  matchingEvents = (function() {
    var _i, _len, _results;
    _results = [];
    for (_i = 0, _len = events.length; _i < _len; _i++) {
      event = events[_i];
      if (anyMatchingValue(event, value)) {
        _results.push(event);
      }
    }
    return _results;
  })();
  return matchingEvents;
};

this.filterEventsByValue = filterEventsByValue;

filterEventsByField = function(events, field, value) {
  var event, respondingEvents, _i, _len, _results;
  respondingEvents = (function() {
    var _i, _len, _results;
    _results = [];
    for (_i = 0, _len = events.length; _i < _len; _i++) {
      event = events[_i];
      if (event.respondTo(field)) {
        _results.push(event);
      }
    }
    return _results;
  })();
  _results = [];
  for (_i = 0, _len = respondingEvents.length; _i < _len; _i++) {
    event = respondingEvents[_i];
    if (value.match(event[field]())) {
      _results.push(event);
    }
  }
  return _results;
};

this.filterEventsByField = filterEventsByField;

getCodes = function(oid) {
  return OidDictionary[oid];
};

this.getCodes = getCodes;

CrossProduct = (function(_super) {

  __extends(CrossProduct, _super);

  function CrossProduct(allEventLists) {
    var event, eventList, _i, _j, _len, _len1;
    CrossProduct.__super__.constructor.call(this);
    this.eventLists = [];
    for (_i = 0, _len = allEventLists.length; _i < _len; _i++) {
      eventList = allEventLists[_i];
      this.eventLists.push(eventList);
      for (_j = 0, _len1 = eventList.length; _j < _len1; _j++) {
        event = eventList[_j];
        this.push(event);
      }
    }
  }

  return CrossProduct;

})(Array);

XPRODUCT = function() {
  var eventLists;
  eventLists = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
  return Specifics.intersectAll(new CrossProduct(eventLists), eventLists);
};

this.XPRODUCT = XPRODUCT;

UNION = function() {
  var event, eventList, eventLists, union, _i, _j, _len, _len1;
  eventLists = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
  union = [];
  for (_i = 0, _len = eventLists.length; _i < _len; _i++) {
    eventList = eventLists[_i];
    for (_j = 0, _len1 = eventList.length; _j < _len1; _j++) {
      event = eventList[_j];
      union.push(event);
    }
  }
  return Specifics.unionAll(union, eventLists);
};

this.UNION = UNION;

COUNT = function(events, range) {
  var count, result;
  count = events.length;
  result = new Boolean(range.match(count));
  return applySpecificOccurrenceSubset('COUNT', Specifics.maintainSpecifics(result, events), range);
};

this.COUNT = COUNT;

PREVSUM = function(eventList) {
  return eventList;
};

this.PREVSUM = PREVSUM;

getIVL = function(eventOrTimeStamp) {
  var ts;
  if (eventOrTimeStamp.asIVL_TS) {
    return eventOrTimeStamp.asIVL_TS();
  } else {
    ts = new TS();
    ts.date = eventOrTimeStamp;
    return new IVL_TS(ts, ts);
  }
};

this.getIVL = getIVL;

eventAccessor = {
  'DURING': 'low',
  'OVERLAP': 'low',
  'SBS': 'low',
  'SAS': 'low',
  'SBE': 'low',
  'SAE': 'low',
  'EBS': 'high',
  'EAS': 'high',
  'EBE': 'high',
  'EAE': 'high',
  'SDU': 'low',
  'EDU': 'high',
  'ECW': 'high',
  'SCW': 'low',
  'ECWS': 'high',
  'SCWE': 'low',
  'CONCURRENT': 'low'
};

boundAccessor = {
  'DURING': 'low',
  'OVERLAP': 'low',
  'SBS': 'low',
  'SAS': 'low',
  'SBE': 'high',
  'SAE': 'high',
  'EBS': 'low',
  'EAS': 'low',
  'EBE': 'high',
  'EAE': 'high',
  'SDU': 'low',
  'EDU': 'low',
  'ECW': 'high',
  'SCW': 'low',
  'ECWS': 'low',
  'SCWE': 'high',
  'CONCURRENT': 'low'
};

withinRange = function(method, eventIVL, boundIVL, range) {
  var boundTS, eventTS;
  eventTS = eventIVL[eventAccessor[method]];
  boundTS = boundIVL[boundAccessor[method]];
  return range.match(eventTS.difference(boundTS, range.unit()));
};

this.withinRange = withinRange;

eventMatchesBounds = function(event, bounds, methodName, range) {
  var bound, boundIVL, boundList, currentMatches, eventIVL, matchingBounds, result, _i, _len, _ref;
  if (bounds.eventLists) {
    matchingBounds = [];
    _ref = bounds.eventLists;
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      boundList = _ref[_i];
      currentMatches = eventMatchesBounds(event, boundList, methodName, range);
      if (currentMatches.length === 0) {
        return [];
      }
      matchingBounds = matchingBounds.concat(currentMatches);
    }
    return Specifics.maintainSpecifics(matchingBounds, bounds);
  } else {
    eventIVL = getIVL(event);
    matchingBounds = (function() {
      var _j, _len1, _results;
      _results = [];
      for (_j = 0, _len1 = bounds.length; _j < _len1; _j++) {
        bound = bounds[_j];
        if ((boundIVL = getIVL(bound), result = eventIVL[methodName](boundIVL), result && range ? result && (result = withinRange(methodName, eventIVL, boundIVL, range)) : void 0, result)) {
          _results.push(bound);
        }
      }
      return _results;
    })();
    return Specifics.maintainSpecifics(matchingBounds, bounds);
  }
};

this.eventMatchesBounds = eventMatchesBounds;

eventsMatchBounds = function(events, bounds, methodName, range) {
  var event, hasSpecificOccurrence, matchingBounds, matchingEvents, specificContext, _i, _len;
  if (bounds.length === void 0) {
    bounds = [bounds];
  }
  if (events.length === void 0) {
    events = [events];
  }
  specificContext = new Specifics();
  hasSpecificOccurrence = (events.specific_occurrence != null) || (bounds.specific_occurrence != null);
  matchingEvents = [];
  matchingEvents.specific_occurrence = events.specific_occurrence;
  for (_i = 0, _len = events.length; _i < _len; _i++) {
    event = events[_i];
    matchingBounds = eventMatchesBounds(event, bounds, methodName, range);
    if (matchingBounds.length > 0) {
      matchingEvents.push(event);
    }
    if (hasSpecificOccurrence) {
      matchingEvents.specific_occurrence = events.specific_occurrence;
      specificContext.addRows(Row.buildRowsForMatching(events.specific_occurrence, event, bounds.specific_occurrence, matchingBounds));
    } else {
      specificContext.addIdentityRow();
    }
  }
  matchingEvents.specificContext = specificContext.finalizeEvents(events.specificContext, bounds.specificContext);
  return matchingEvents;
};

this.eventsMatchBounds = eventsMatchBounds;

DURING = function(events, bounds, offset) {
  return eventsMatchBounds(events, bounds, "DURING", offset);
};

this.DURING = DURING;

OVERLAP = function(events, bounds, offset) {
  return eventsMatchBounds(events, bounds, "OVERLAP", offset);
};

this.OVERLAP = OVERLAP;

SBS = function(events, bounds, offset) {
  return eventsMatchBounds(events, bounds, "SBS", offset);
};

this.SBS = SBS;

SAS = function(events, bounds, offset) {
  return eventsMatchBounds(events, bounds, "SAS", offset);
};

this.SAS = SAS;

SBE = function(events, bounds, offset) {
  return eventsMatchBounds(events, bounds, "SBE", offset);
};

this.SBE = SBE;

SAE = function(events, bounds, offset) {
  return eventsMatchBounds(events, bounds, "SAE", offset);
};

this.SAE = SAE;

EBS = function(events, bounds, offset) {
  return eventsMatchBounds(events, bounds, "EBS", offset);
};

this.EBS = EBS;

EAS = function(events, bounds, offset) {
  return eventsMatchBounds(events, bounds, "EAS", offset);
};

this.EAS = EAS;

EBE = function(events, bounds, offset) {
  return eventsMatchBounds(events, bounds, "EBE", offset);
};

this.EBE = EBE;

EAE = function(events, bounds, offset) {
  return eventsMatchBounds(events, bounds, "EAE", offset);
};

this.EAE = EAE;

SDU = function(events, bounds, offset) {
  return eventsMatchBounds(events, bounds, "SDU", offset);
};

this.SDU = SDU;

EDU = function(events, bounds, offset) {
  return eventsMatchBounds(events, bounds, "EDU", offset);
};

this.EDU = EDU;

ECW = function(events, bounds, offset) {
  return eventsMatchBounds(events, bounds, "ECW", offset);
};

this.ECW = ECW;

SCW = function(events, bounds, offset) {
  return eventsMatchBounds(events, bounds, "SCW", offset);
};

this.SCW = SCW;

ECWS = function(events, bounds, offset) {
  return eventsMatchBounds(events, bounds, "ECWS", offset);
};

this.ECWS = ECWS;

SCWE = function(events, bounds, offset) {
  return eventsMatchBounds(events, bounds, "SCWE", offset);
};

this.SCWE = SCWE;

CONCURRENT = function(events, bounds, offset) {
  return eventsMatchBounds(events, bounds, "CONCURRENT", offset);
};

this.CONCURRENT = CONCURRENT;

dateSortDescending = function(a, b) {
  return b.timeStamp().getTime() - a.timeStamp().getTime();
};

this.dateSortDescending = dateSortDescending;

dateSortAscending = function(a, b) {
  return a.timeStamp().getTime() - b.timeStamp().getTime();
};

this.dateSortAscending = dateSortAscending;

applySpecificOccurrenceSubset = function(operator, result, range, calculateSpecifics) {
  if ((result.specificContext != null)) {
    if ((range != null)) {
      result.specificContext = result.specificContext[operator](range);
    } else {
      result.specificContext = result.specificContext[operator]();
    }
  }
  return result;
};

FIRST = function(events) {
  var result;
  result = [];
  if (events.length > 0) {
    result = [events.sort(dateSortAscending)[0]];
  }
  return applySpecificOccurrenceSubset('FIRST', Specifics.maintainSpecifics(result, events));
};

this.FIRST = FIRST;

SECOND = function(events) {
  var result;
  result = [];
  if (events.length > 1) {
    result = [events.sort(dateSortAscending)[1]];
  }
  return applySpecificOccurrenceSubset('SECOND', Specifics.maintainSpecifics(result, events));
};

this.SECOND = SECOND;

THIRD = function(events) {
  var result;
  result = [];
  if (events.length > 2) {
    result = [events.sort(dateSortAscending)[2]];
  }
  return applySpecificOccurrenceSubset('THIRD', Specifics.maintainSpecifics(result, events));
};

this.THIRD = THIRD;

FOURTH = function(events) {
  var result;
  result = [];
  if (events.length > 3) {
    result = [events.sort(dateSortAscending)[3]];
  }
  return applySpecificOccurrenceSubset('FOURTH', Specifics.maintainSpecifics(result, events));
};

this.FOURTH = FOURTH;

FIFTH = function(events) {
  var result;
  result = [];
  if (events.length > 4) {
    result = [events.sort(dateSortAscending)[4]];
  }
  return applySpecificOccurrenceSubset('FIFTH', Specifics.maintainSpecifics(result, events));
};

this.FIFTH = FIFTH;

RECENT = function(events) {
  var result;
  result = [];
  if (events.length > 0) {
    result = [events.sort(dateSortDescending)[0]];
  }
  return applySpecificOccurrenceSubset('RECENT', Specifics.maintainSpecifics(result, events));
};

this.RECENT = RECENT;

LAST = function(events) {
  return RECENT(events);
};

this.LAST = LAST;

valueSortDescending = function(a, b) {
  var va, vb;
  va = vb = Infinity;
  if (a.value) {
    va = a.value()["scalar"];
  }
  if (b.value) {
    vb = b.value()["scalar"];
  }
  if (va === vb) {
    return 0;
  } else {
    return vb - va;
  }
};

this.valueSortDescending = valueSortDescending;

valueSortAscending = function(a, b) {
  var va, vb;
  va = vb = Infinity;
  if (a.value) {
    va = a.value()["scalar"];
  }
  if (b.value) {
    vb = b.value()["scalar"];
  }
  if (va === vb) {
    return 0;
  } else {
    return va - vb;
  }
};

this.valueSortAscending = valueSortAscending;

MIN = function(events, range) {
  var minValue, result;
  minValue = Infinity;
  if (events.length > 0) {
    minValue = events.sort(valueSortAscending)[0].value()["scalar"];
  }
  result = new Boolean(range.match(minValue));
  return applySpecificOccurrenceSubset('MIN', Specifics.maintainSpecifics(result, events), range);
};

this.MIN = MIN;

MAX = function(events, range) {
  var maxValue, result;
  maxValue = -Infinity;
  if (events.length > 0) {
    maxValue = events.sort(valueSortDescending)[0].value()["scalar"];
  }
  result = new Boolean(range.match(maxValue));
  return applySpecificOccurrenceSubset('MAX', Specifics.maintainSpecifics(result, events), range);
};

this.MAX = MAX;

this.OidDictionary = {};

hqmfjs = hqmfjs || {};

this.hqmfjs = this.hqmfjs || {};

// #########################
// ### PATIENT EXTENSION ####
// #########################

var _this = this;

hQuery.Patient.prototype.procedureResults = function() {
  return this.results().concat(this.vitalSigns()).concat(this.procedures());
};

hQuery.Patient.prototype.allProcedures = function() {
  return this.procedures().concat(this.immunizations()).concat(this.medications());
};

hQuery.Patient.prototype.laboratoryTests = function() {
  return this.results().concat(this.vitalSigns());
};

hQuery.Patient.prototype.allMedications = function() {
  return this.medications().concat(this.immunizations());
};

hQuery.Patient.prototype.allProblems = function() {
  return this.conditions().concat(this.socialHistories()).concat(this.procedures());
};

hQuery.Patient.prototype.allDevices = function() {
  return this.conditions().concat(this.procedures()).concat(this.careGoals()).concat(this.medicalEquipment());
};

hQuery.Patient.prototype.activeDiagnoses = function() {
  return this.conditions().concat(this.socialHistories()).withStatuses(['active']);
};

hQuery.Patient.prototype.inactiveDiagnoses = function() {
  return this.conditions().concat(this.socialHistories()).withStatuses(['inactive']);
};

hQuery.Patient.prototype.resolvedDiagnoses = function() {
  return this.conditions().concat(this.socialHistories()).withStatuses(['resolved']);
};

hQuery.CodedEntry.prototype.asIVL_TS = function() {
  var tsHigh, tsLow;
  tsLow = new TS();
  tsLow.date = this.startDate() || this.date() || null;
  tsHigh = new TS();
  tsHigh.date = this.endDate() || this.date() || null;
  return new IVL_TS(tsLow, tsHigh);
};

hQuery.CodedEntry.prototype.respondTo = function(functionName) {
  return typeof this[functionName] === "function";
};

hQuery.CodedEntryList.prototype.isTrue = function() {
  return this.length !== 0;
};

hQuery.CodedEntryList.prototype.isFalse = function() {
  return this.length === 0;
};

Array.prototype.isTrue = function() {
  return this.length !== 0;
};

Array.prototype.isFalse = function() {
  return this.length === 0;
};

Boolean.prototype.isTrue = function() {
  return this == true;
};

Boolean.prototype.isFalse = function() {
  return this == false;
};

// #########################
// ##### LOGGING UTILS ######
// #########################


this.Logger = (function() {

  function Logger() {}

  Logger.logger = [];

  Logger.info = function(string) {
    return this.logger.push("" + (Logger.indent()) + string);
  };

  Logger.enabled = true;

  Logger.initialized = false;

  Logger.indentCount = 0;

  Logger.indent = function() {
    var indent, num, _i, _ref;
    indent = '';
    for (num = _i = 0, _ref = this.indentCount * 8; 0 <= _ref ? _i <= _ref : _i >= _ref; num = 0 <= _ref ? ++_i : --_i) {
      indent += ' ';
    }
    return indent;
  };

  Logger.stringify = function(object) {
    if (!_.isUndefined(object) && !_.isUndefined(object.length)) {
      return "" + object.length + " entries";
    } else {
      return "" + object;
    }
  };

  Logger.asBoolean = function(object) {
    if (!_.isUndefined(object) && !_.isUndefined(object.length)) {
      return object.length > 0;
    } else {
      return object;
    }
  };

  Logger.toJson = function(value) {
    if (typeof tojson === 'function') {
      return tojson(value);
    } else {
      return JSON.stringify(value);
    }
  };

  Logger.classNameFor = function(object) {
    var funcNameRegex, results;
    funcNameRegex = /function(.+)\(/;
    results = funcNameRegex.exec(object.constructor.toString());
    if (results && results.length > 1) {
      return results[1];
    } else {
      return "";
    }
  };

  Logger.codedValuesAsString = function(codedValues) {
    return "[" + _.reduce(codedValues, function(memo, entry) {
      memo.push("" + (entry.codeSystemName()) + ":" + (entry.code()));
      return memo;
    }, []).join(',') + "]";
  };

  return Logger;

})();

this.enableMeasureLogging = function(hqmfjs) {
  return _.each(_.functions(hqmfjs), function(method) {
    return hqmfjs[method] = _.wrap(hqmfjs[method], function(func, patient) {
      var result;
      Logger.info("" + method + ":");
      Logger.indentCount++;
      result = func(patient);
      Logger.indentCount--;
      Logger.info("" + method + " -> " + (Logger.asBoolean(result)));
      return result;
    });
  });
};

this.enableLogging = function() {
  if (!Logger.initialized) {
    Logger.initialized = true;
    _.each(_.functions(hQuery.Patient.prototype), function(method) {
      if (hQuery.Patient.prototype[method].length === 0) {
        return hQuery.Patient.prototype[method] = _.wrap(hQuery.Patient.prototype[method], function(func) {
          var result;
          Logger.info("called patient." + method + "():");
          func = _.bind(func, this);
          result = func();
          Logger.info("patient." + method + "() -> " + (Logger.stringify(result)));
          return result;
        });
      } else {
        return hQuery.Patient.prototype[method] = _.wrap(hQuery.Patient.prototype[method], function(func) {
          var args, result;
          args = Array.prototype.slice.call(arguments, 1);
          Logger.info("called patient." + method + "(" + args + "):");
          result = func.apply(this, args);
          Logger.info("patient." + method + "(" + args + ") -> " + (Logger.stringify(result)));
          return result;
        });
      }
    });
    hQuery.CodedEntryList.prototype.match = _.wrap(hQuery.CodedEntryList.prototype.match, function(func, codeSet, start, end) {
      var result;
      func = _.bind(func, this, codeSet, start, end);
      result = func(codeSet, start, end);
      Logger.info("matched -> " + (Logger.stringify(result)));
      return result;
    });
    this.getCodes = _.wrap(this.getCodes, function(func, oid) {
      var codes;
      codes = func(oid);
      Logger.info("accessed codes: " + oid);
      return codes;
    });
    this.atLeastOneTrue = _.wrap(this.atLeastOneTrue, function(func) {
      var args, result;
      args = Array.prototype.slice.call(arguments, 1);
      Logger.info("called atLeastOneTrue(" + args + "):");
      Logger.indentCount++;
      result = func.apply(this, args);
      Logger.indentCount--;
      Logger.info("atLeastOneTrue -> " + result);
      return result;
    });
    this.allTrue = _.wrap(this.allTrue, function(func) {
      var args, result;
      args = Array.prototype.slice.call(arguments, 1);
      Logger.info("called allTrue(" + args + "):");
      Logger.indentCount++;
      result = func.apply(this, args);
      Logger.indentCount--;
      Logger.info("allTrue -> " + result);
      return result;
    });
    this.allFalse = _.wrap(this.allFalse, function(func) {
      var args, result;
      args = Array.prototype.slice.call(arguments, 1);
      Logger.info("called allFalse(" + args + "):");
      Logger.indentCount++;
      result = func.apply(this, args);
      Logger.indentCount--;
      Logger.info("allFalse -> " + result);
      return result;
    });
    this.atLeastOneFalse = _.wrap(this.atLeastOneFalse, function(func) {
      var args, result;
      args = Array.prototype.slice.call(arguments, 1);
      Logger.info("called atLeastOneFalse(" + args + "):");
      Logger.indentCount++;
      result = func.apply(this, args);
      Logger.indentCount--;
      Logger.info("atLeastOneFalse -> " + result);
      return result;
    });
    return this.eventsMatchBounds = _.wrap(this.eventsMatchBounds, function(func, events, bounds, methodName, range) {
      var args, result;
      args = Array.prototype.slice.call(arguments, 1);
      result = func(events, bounds, methodName, range);
      Logger.info("" + methodName + "(Events: " + (Logger.stringify(events)) + ", Bounds: " + (Logger.stringify(bounds)) + ", Range: " + (Logger.toJson(range)) + ") -> " + (Logger.stringify(result)));
      return result;
    });
  }
};

// #########################
// ## SPECIFIC OCCURRENCES ##
// #########################

var Row, Specifics, bind, wrap,
  __slice = [].slice;

wrap = function(func, wrapper) {
  return function() {
    var args;
    args = [func].concat(Array.prototype.slice.call(arguments, 0));
    return wrapper.apply(this, args);
  };
};

bind = function(func, context) {
  var args, bound;
  if (func.bind === Function.prototype.bind && Function.prototype.bind) {
    return Function.prototype.bind.apply(func, Array.prototype.slice.call(arguments, 1));
  }
  if (typeof func !== "function") {
    throw new TypeError;
  }
  args = Array.prototype.slice.call(arguments, 2);
  return bound = function() {
    var ctor, result, self;
    ctor = function() {};
    if (!(this instanceof bound)) {
      return func.apply(context, args.concat(Array.prototype.slice.call(arguments)));
    }
    ctor.prototype = func.prototype;
    self = new ctor;
    result = func.apply(self, args.concat(Array.prototype.slice.call(arguments)));
    if (Object(result) === result) {
      return result;
    }
    return self;
  };
};

Array.prototype.unique = function() {
  var key, output, value, _i, _ref, _results;
  output = {};
  for (key = _i = 0, _ref = this.length; 0 <= _ref ? _i < _ref : _i > _ref; key = 0 <= _ref ? ++_i : --_i) {
    output[this[key]] = this[key];
  }
  _results = [];
  for (key in output) {
    value = output[key];
    _results.push(value);
  }
  return _results;
};

Array.prototype.reduce = function(accumulator) {
  var curr, i, l;
  if (this === null || this === void 0) {
    throw new TypeError("Object is null or undefined");
  }
  i = 0;
  l = this.length >> 0;
  curr = void 0;
  if (typeof accumulator !== "function") {
    throw new TypeError("First argument is not callable");
  }
  if (arguments.length < 2) {
    if (l === 0) {
      throw new TypeError("Array length is 0 and no second argument");
    }
    curr = this[0];
    i = 1;
  } else {
    curr = arguments[1];
  }
  while (i < l) {
    if (i in this) {
      curr = accumulator.call(void 0, curr, this[i], i, this);
    }
    ++i;
  }
  return curr;
};

/*
  {
    rows: [
      [1,3,5],
      [1,7,8],
    ]
  }
*/


Specifics = (function() {

  Specifics.OCCURRENCES;

  Specifics.KEY_LOOKUP;

  Specifics.TYPE_LOOKUP;

  Specifics.INITIALIZED = false;

  Specifics.PATIENT = null;

  Specifics.ANY = '*';

  Specifics.initialize = function() {
    var hqmfjs, i, occurrenceKey, occurrences, patient, _base, _i, _len, _name, _results;
    patient = arguments[0], hqmfjs = arguments[1], occurrences = 3 <= arguments.length ? __slice.call(arguments, 2) : [];
    Specifics.OCCURRENCES = occurrences;
    Specifics.KEY_LOOKUP = {};
    Specifics.INDEX_LOOKUP = {};
    Specifics.TYPE_LOOKUP = {};
    Specifics.FUNCTION_LOOKUP = {};
    Specifics.PATIENT = patient;
    Specifics.HQMFJS = hqmfjs;
    _results = [];
    for (i = _i = 0, _len = occurrences.length; _i < _len; i = ++_i) {
      occurrenceKey = occurrences[i];
      Specifics.KEY_LOOKUP[i] = occurrenceKey.id;
      Specifics.INDEX_LOOKUP[occurrenceKey.id] = i;
      Specifics.FUNCTION_LOOKUP[i] = occurrenceKey["function"];
      (_base = Specifics.TYPE_LOOKUP)[_name = occurrenceKey.type] || (_base[_name] = []);
      _results.push(Specifics.TYPE_LOOKUP[occurrenceKey.type].push(i));
    }
    return _results;
  };

  function Specifics(rows) {
    if (rows == null) {
      rows = [];
    }
    this.rows = rows;
  }

  Specifics.prototype.addRows = function(rows) {
    return this.rows = this.rows.concat(rows);
  };

  Specifics.prototype.removeDuplicateRows = function() {
    var deduped, row, _i, _len, _ref;
    deduped = new Specifics();
    _ref = this.rows;
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      row = _ref[_i];
      if (!deduped.hasExactRow(row)) {
        deduped.addRows([row]);
      }
    }
    return deduped;
  };

  Specifics.prototype.hasExactRow = function(other) {
    var row, _i, _len, _ref;
    _ref = this.rows;
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      row = _ref[_i];
      if (row.equals(other)) {
        return true;
      }
    }
    return false;
  };

  Specifics.prototype.union = function(other) {
    var value;
    value = new Specifics();
    value.rows = this.rows.concat(other.rows);
    return value.removeDuplicateRows();
  };

  Specifics.prototype.intersect = function(other) {
    var leftRow, result, rightRow, value, _i, _j, _len, _len1, _ref, _ref1;
    value = new Specifics();
    _ref = this.rows;
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      leftRow = _ref[_i];
      _ref1 = other.rows;
      for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
        rightRow = _ref1[_j];
        result = leftRow.intersect(rightRow);
        if (result != null) {
          value.rows.push(result);
        }
      }
    }
    return value.removeDuplicateRows();
  };

  Specifics.prototype.getLeftMost = function() {
    var leftMost, row, _i, _len, _ref;
    leftMost = void 0;
    _ref = this.rows;
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      row = _ref[_i];
      if (leftMost == null) {
        leftMost = row.leftMost;
      }
      if (leftMost !== row.leftMost) {
        return void 0;
      }
    }
    return leftMost;
  };

  Specifics.prototype.negate = function() {
    var allValues, cartesian, i, index, key, keys, negatedRows, occurrences, row, values, _i, _j, _k, _len, _len1, _len2, _ref;
    negatedRows = [];
    keys = [];
    allValues = [];
    _ref = this.specificsWithValues();
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      index = _ref[_i];
      keys.push(Specifics.KEY_LOOKUP[index]);
      allValues.push(Specifics.HQMFJS[Specifics.FUNCTION_LOOKUP[index]](Specifics.PATIENT));
    }
    cartesian = Specifics._generateCartisian(allValues);
    for (_j = 0, _len1 = cartesian.length; _j < _len1; _j++) {
      values = cartesian[_j];
      occurrences = {};
      for (i = _k = 0, _len2 = keys.length; _k < _len2; i = ++_k) {
        key = keys[i];
        occurrences[key] = values[i];
      }
      row = new Row(this.getLeftMost(), occurrences);
      if (!this.hasRow(row)) {
        negatedRows.push(row);
      }
    }
    return (new Specifics(negatedRows)).compactReusedEvents();
  };

  Specifics._generateCartisian = function(allValues) {
    return Array.prototype.reduce.call(allValues, function(as, bs) {
      var a, b, product, _i, _j, _len, _len1;
      product = [];
      for (_i = 0, _len = as.length; _i < _len; _i++) {
        a = as[_i];
        for (_j = 0, _len1 = bs.length; _j < _len1; _j++) {
          b = bs[_j];
          product.push(a.concat(b));
        }
      }
      return product;
    }, [[]]);
  };

  Specifics.prototype.compactReusedEvents = function() {
    var goodRow, ids, index, indexes, myRow, newRows, type, _i, _j, _len, _len1, _ref, _ref1;
    newRows = [];
    _ref = this.rows;
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      myRow = _ref[_i];
      goodRow = true;
      _ref1 = Specifics.TYPE_LOOKUP;
      for (type in _ref1) {
        indexes = _ref1[type];
        ids = [];
        for (_j = 0, _len1 = indexes.length; _j < _len1; _j++) {
          index = indexes[_j];
          if (myRow.values[index] !== Specifics.ANY) {
            ids.push(myRow.values[index].id);
          }
        }
        goodRow && (goodRow = ids.length === ids.unique().length);
      }
      if (goodRow) {
        newRows.push(myRow);
      }
    }
    return new Specifics(newRows);
  };

  Specifics.prototype.hasRow = function(row) {
    var found, myRow, result, _i, _len, _ref;
    found = false;
    _ref = this.rows;
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      myRow = _ref[_i];
      result = myRow.intersect(row);
      if (result != null) {
        return true;
      }
    }
    return false;
  };

  Specifics.prototype.hasRows = function() {
    return this.rows.length > 0;
  };

  Specifics.prototype.specificsWithValues = function() {
    var foundSpecificIndexes, row, _i, _len, _ref;
    foundSpecificIndexes = [];
    _ref = this.rows;
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      row = _ref[_i];
      foundSpecificIndexes = foundSpecificIndexes.concat(row.specificsWithValues());
    }
    return foundSpecificIndexes.unique();
  };

  Specifics.prototype.hasSpecifics = function() {
    var anyHaveSpecifics, row, _i, _len, _ref;
    anyHaveSpecifics = false;
    _ref = this.rows;
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      row = _ref[_i];
      anyHaveSpecifics || (anyHaveSpecifics = row.hasSpecifics());
    }
    return anyHaveSpecifics;
  };

  Specifics.prototype.finalizeEvents = function(eventsContext, boundsContext) {
    var result;
    result = this;
    if ((eventsContext != null)) {
      result = result.intersect(eventsContext);
    }
    if ((boundsContext != null)) {
      result = result.intersect(boundsContext);
    }
    return result.compactReusedEvents();
  };

  Specifics.prototype.group = function() {
    var groupedRows, row, _i, _len, _name, _ref;
    groupedRows = {};
    _ref = this.rows;
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      row = _ref[_i];
      groupedRows[_name = row.groupKeyForLeftMost()] || (groupedRows[_name] = []);
      groupedRows[row.groupKeyForLeftMost()].push(row);
    }
    return groupedRows;
  };

  Specifics.prototype.COUNT = function(range) {
    return this.applyRangeSubset(COUNT, range);
  };

  Specifics.prototype.MIN = function(range) {
    return this.applyRangeSubset(MIN, range);
  };

  Specifics.prototype.MAX = function(range) {
    return this.applyRangeSubset(MAX, range);
  };

  Specifics.prototype.applyRangeSubset = function(func, range) {
    var group, groupKey, groupedRows, resultRows;
    if (!this.hasSpecifics()) {
      return this;
    }
    resultRows = [];
    groupedRows = this.group();
    for (groupKey in groupedRows) {
      group = groupedRows[groupKey];
      if (func(Specifics.extractEventsForLeftMost(group), range).isTrue()) {
        resultRows = resultRows.concat(group);
      }
    }
    return new Specifics(resultRows);
  };

  Specifics.prototype.FIRST = function() {
    return this.applySubset(FIRST);
  };

  Specifics.prototype.SECOND = function() {
    return this.applySubset(SECOND);
  };

  Specifics.prototype.THIRD = function() {
    return this.applySubset(THIRD);
  };

  Specifics.prototype.FOURTH = function() {
    return this.applySubset(FOURTH);
  };

  Specifics.prototype.FIFTH = function() {
    return this.applySubset(FIFTH);
  };

  Specifics.prototype.LAST = function() {
    return this.applySubset(LAST);
  };

  Specifics.prototype.RECENT = function() {
    return this.applySubset(RECENT);
  };

  Specifics.prototype.applySubset = function(func) {
    var entries, group, groupKey, groupedRows, resultRows;
    if (!this.hasSpecifics()) {
      return this;
    }
    resultRows = [];
    groupedRows = this.group();
    for (groupKey in groupedRows) {
      group = groupedRows[groupKey];
      entries = func(Specifics.extractEventsForLeftMost(group));
      if (entries.length > 0) {
        resultRows.push(entries[0].specificRow);
      }
    }
    return new Specifics(resultRows);
  };

  Specifics.prototype.addIdentityRow = function() {
    return this.addRows(Specifics.identity().rows);
  };

  Specifics.identity = function() {
    return new Specifics([new Row(void 0)]);
  };

  Specifics.extractEventsForLeftMost = function(rows) {
    var events, row, _i, _len;
    events = [];
    for (_i = 0, _len = rows.length; _i < _len; _i++) {
      row = rows[_i];
      events.push(Specifics.extractEvent(row.leftMost, row));
    }
    return events;
  };

  Specifics.extractEvents = function(key, rows) {
    var events, row, _i, _len;
    events = [];
    for (_i = 0, _len = rows.length; _i < _len; _i++) {
      row = rows[_i];
      events.push(Specifics.extractEvent(key, row));
    }
    return events;
  };

  Specifics.extractEvent = function(key, row) {
    var entry, index;
    index = Specifics.INDEX_LOOKUP[key];
    if (index != null) {
      entry = row.values[index];
    } else {
      entry = row.tempValue;
    }
    entry = new hQuery.CodedEntry(entry.json);
    entry.specificRow = row;
    return entry;
  };

  Specifics.validate = function() {
    var populations, value;
    populations = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
    value = Specifics.intersectAll(new Boolean(populations[0].isTrue()), populations);
    return value.isTrue() && value.specificContext.hasRows();
  };

  Specifics.intersectAll = function(boolVal, values, negate) {
    var result, value, _i, _len;
    if (negate == null) {
      negate = false;
    }
    result = new Specifics();
    result.addIdentityRow();
    for (_i = 0, _len = values.length; _i < _len; _i++) {
      value = values[_i];
      if (value.specificContext != null) {
        result = result.intersect(value.specificContext);
      }
    }
    if (negate && (!result.hasRows() || result.hasSpecifics())) {
      result = result.negate();
      result = result.compactReusedEvents();
      boolVal = new Boolean(true);
    }
    boolVal.specificContext = result.compactReusedEvents();
    return boolVal;
  };

  Specifics.unionAll = function(boolVal, values, negate) {
    var result, value, _i, _len;
    if (negate == null) {
      negate = false;
    }
    result = new Specifics();
    for (_i = 0, _len = values.length; _i < _len; _i++) {
      value = values[_i];
      if ((value.specificContext != null) && (value.isTrue() || negate)) {
        if (value.specificContext != null) {
          result = result.union(value.specificContext);
        }
      }
    }
    if (negate && result.hasSpecifics()) {
      result = result.negate();
      boolVal = new Boolean(true);
    }
    boolVal.specificContext = result;
    return boolVal;
  };

  Specifics.maintainSpecifics = function(newElement, existingElement) {
    newElement.specificContext = existingElement.specificContext;
    newElement.specific_occurrence = existingElement.specific_occurrence;
    return newElement;
  };

  return Specifics;

})();

this.Specifics = Specifics;

Row = (function() {

  function Row(leftMost, occurrences) {
    var i, key, value, _i, _ref;
    if (occurrences == null) {
      occurrences = {};
    }
    if (typeof leftMost !== 'string' && typeof leftMost !== 'undefined') {
      throw "left most key must be a string or undefined was: " + leftMost;
    }
    this.length = Specifics.OCCURRENCES.length;
    this.values = [];
    this.leftMost = leftMost;
    this.tempValue = occurrences[void 0];
    for (i = _i = 0, _ref = this.length; 0 <= _ref ? _i < _ref : _i > _ref; i = 0 <= _ref ? ++_i : --_i) {
      key = Specifics.KEY_LOOKUP[i];
      value = occurrences[key] || Specifics.ANY;
      this.values[i] = value;
    }
  }

  Row.prototype.hasSpecifics = function() {
    var foundSpecific, i, _i, _ref;
    this.length = Specifics.OCCURRENCES.length;
    foundSpecific = false;
    for (i = _i = 0, _ref = this.length; 0 <= _ref ? _i < _ref : _i > _ref; i = 0 <= _ref ? ++_i : --_i) {
      if (this.values[i] !== Specifics.ANY) {
        return true;
      }
    }
    return false;
  };

  Row.prototype.specificsWithValues = function() {
    var foundSpecificIndexes, i, _i, _ref;
    this.length = Specifics.OCCURRENCES.length;
    foundSpecificIndexes = [];
    for (i = _i = 0, _ref = this.length; 0 <= _ref ? _i < _ref : _i > _ref; i = 0 <= _ref ? ++_i : --_i) {
      if ((this.values[i] != null) && this.values[i] !== Specifics.ANY) {
        foundSpecificIndexes.push(i);
      }
    }
    return foundSpecificIndexes;
  };

  Row.prototype.equals = function(other) {
    var equal, i, value, _i, _len, _ref;
    equal = true;
    equal && (equal = Row.valuesEqual(this.tempValue, other.tempValue));
    _ref = this.values;
    for (i = _i = 0, _len = _ref.length; _i < _len; i = ++_i) {
      value = _ref[i];
      equal && (equal = Row.valuesEqual(value, other.values[i]));
    }
    return equal;
  };

  Row.prototype.intersect = function(other) {
    var allMatch, i, intersectedRow, result, value, _i, _len, _ref;
    intersectedRow = new Row(this.leftMost, {});
    intersectedRow.tempValue = this.tempValue;
    allMatch = true;
    _ref = this.values;
    for (i = _i = 0, _len = _ref.length; _i < _len; i = ++_i) {
      value = _ref[i];
      result = Row.match(value, other.values[i]);
      if (result != null) {
        intersectedRow.values[i] = result;
      } else {
        return void 0;
      }
    }
    return intersectedRow;
  };

  Row.prototype.groupKeyForLeftMost = function() {
    return this.groupKey(this.leftMost);
  };

  Row.prototype.groupKey = function(key) {
    var i, keyForGroup, value, _i, _ref;
    if (key == null) {
      key = null;
    }
    keyForGroup = '';
    for (i = _i = 0, _ref = this.length; 0 <= _ref ? _i < _ref : _i > _ref; i = 0 <= _ref ? ++_i : --_i) {
      value = Specifics.ANY;
      if (this.values[i] !== Specifics.ANY) {
        value = this.values[i].id;
      }
      if (Specifics.KEY_LOOKUP[i] === key) {
        keyForGroup += "X_";
      } else {
        keyForGroup += "" + value + "_";
      }
    }
    return keyForGroup;
  };

  Row.match = function(left, right) {
    if (left === Specifics.ANY) {
      return right;
    }
    if (right === Specifics.ANY) {
      return left;
    }
    if (left.id === right.id) {
      return left;
    }
    return void 0;
  };

  Row.valuesEqual = function(left, right) {
    if (!(left != null) && !(right != null)) {
      return true;
    }
    if (!(left != null)) {
      return false;
    }
    if (!(right != null)) {
      return false;
    }
    if (left === Specifics.ANY && right === Specifics.ANY) {
      return true;
    }
    if (left.id === right.id) {
      return true;
    }
    return false;
  };

  Row.buildRowsForMatching = function(entryKey, entry, matchesKey, matches) {
    var match, occurrences, rows, _i, _len;
    rows = [];
    for (_i = 0, _len = matches.length; _i < _len; _i++) {
      match = matches[_i];
      occurrences = {};
      occurrences[entryKey] = entry;
      occurrences[matchesKey] = match;
      rows.push(new Row(entryKey, occurrences));
    }
    return rows;
  };

  Row.buildForDataCriteria = function(entryKey, entries) {
    var entry, occurrences, rows, _i, _len;
    rows = [];
    for (_i = 0, _len = entries.length; _i < _len; _i++) {
      entry = entries[_i];
      occurrences = {};
      occurrences[entryKey] = entry;
      rows.push(new Row(entryKey, occurrences));
    }
    return rows;
  };

  return Row;

})();

this.Row = Row;

/*
  Wrap methods to maintain specificContext and specific_occurrence
*/


hQuery.CodedEntryList.prototype.withStatuses = wrap(hQuery.CodedEntryList.prototype.withStatuses, function(func, statuses, includeUndefined) {
  var context, occurrence, result;
  if (includeUndefined == null) {
    includeUndefined = true;
  }
  context = this.specificContext;
  occurrence = this.specific_occurrence;
  func = bind(func, this);
  result = func(statuses, includeUndefined);
  result.specificContext = context;
  result.specific_occurrence = occurrence;
  return result;
});

hQuery.CodedEntryList.prototype.withNegation = wrap(hQuery.CodedEntryList.prototype.withNegation, function(func, codeSet) {
  var context, occurrence, result;
  context = this.specificContext;
  occurrence = this.specific_occurrence;
  func = bind(func, this);
  result = func(codeSet);
  result.specificContext = context;
  result.specific_occurrence = occurrence;
  return result;
});

hQuery.CodedEntryList.prototype.withoutNegation = wrap(hQuery.CodedEntryList.prototype.withoutNegation, function(func) {
  var context, occurrence, result;
  context = this.specificContext;
  occurrence = this.specific_occurrence;
  func = bind(func, this);
  result = func();
  result.specificContext = context;
  result.specific_occurrence = occurrence;
  return result;
});

hQuery.CodedEntryList.prototype.concat = wrap(hQuery.CodedEntryList.prototype.concat, function(func, otherEntries) {
  var context, occurrence, result;
  context = this.specificContext;
  occurrence = this.specific_occurrence;
  func = bind(func, this);
  result = func(otherEntries);
  result.specificContext = context;
  result.specific_occurrence = occurrence;
  return result;
});

hQuery.CodedEntryList.prototype.match = wrap(hQuery.CodedEntryList.prototype.match, function(func, codeSet, start, end, includeNegated) {
  var context, occurrence, result;
  if (includeNegated == null) {
    includeNegated = false;
  }
  context = this.specificContext;
  occurrence = this.specific_occurrence;
  func = bind(func, this);
  result = func(codeSet, start, end, includeNegated);
  result.specificContext = context;
  result.specific_occurrence = occurrence;
  return result;
});
