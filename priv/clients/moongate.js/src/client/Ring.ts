import { Atlas } from "../client/Atlas";
import { RingMember } from "./RingMember";
import { Meta } from "../common/Meta";
import { Utility } from "../common/Utility";
import { Zone } from "./Zone";

export class Ring {
  atlas: Atlas
  indices: Array<number>
  members: Array<RingMember>
  morphs: any
  morphIndices: Array<number>
  name: string
  schema: any
  subs: any
  subIndices: Array<number>
  zone: string
  zoneName: string
  constructor(zone: string, zoneName: string, name: string, schema: any, atlas: Atlas) {
    this.atlas = atlas;
    this.zone = zone;
    this.zoneName = zoneName;
    this.name = name;
    this.schema = schema;
    this.morphs = {};
    this.indices = [];
    this.morphIndices = [];
    this.subs = {};
    this.subIndices = [];
    this.members = [];
  }
  dropMembers(memberIndices: Array<number>) {
    this.members = this.members.filter((member) => {
      if (memberIndices.indexOf(member.index()) > -1) {
        member.droppedHandler && member.droppedHandler(member);
        return false;
      }
      return true;
    });
    this.refreshIndices();

    return memberIndices;
  }
  dropMorphs(morph: any, memberIndices: Array<number>) {
    this.touchMorph(morph);

    Utility.loop(this.dropMorph.bind(this, morph), memberIndices);
  }
  dropMorph(params: any, index: number) {
    let member = this.getMember(index),
        morph = this.morphs[params.rule][params.key].morphs[index];

    if (morph) {
      member.freezeMorph(params.key, morph, index);
      this.morphs[params.rule][params.key].morphs[index] = undefined;
      delete this.morphs[params.rule][params.key].morphs[index];

      if (Object.keys(this.morphs[params.rule][params.key]).length) {
        this.morphs[params.rule][params.key] = undefined;
        delete this.morphs[params.rule][params.key];
      }
    }
  }
  getMember(index: number) {
    let memberIndex = this.indices.indexOf(index);

    return memberIndex > -1 && this.members[memberIndex];
  }
  insertMember(params: any) {
    let member = new RingMember(this.newMember(params), this, false);

    this.members.push(member);
    this.refreshIndices();

    return member;
  }
  newMember(params: any) {
    let schemaKeys = Object.keys(this.schema),
        result : any = {};

    for (let i = 0, l = schemaKeys.length; i !== l; i++) {
      let key = schemaKeys[i],
          value = params[key];

      value && (result[key] = Ring.castMemberValue(value, this.schema[key]));
    }
    return result;
  }
  refreshIndices() {
    let l : number = this.members.length,
        result : Array<number> = Utility.preallocArray(l, l);

    for (let i = 0; i !== l; i++) {
      result[i] = this.members[i].attributes.__index__;
    }
    this.indices = result;
  }
  touchMorph(morph: any) {
    !this.morphs[morph.rule] && (this.morphs[morph.rule] = {});
    !this.morphs[morph.rule][morph.key] && (this.morphs[morph.rule][morph.key] = {
      morphs: {}
    });
  }
  upsertMember(memberParams: any) : any {
    let index = parseInt(memberParams.__index__, 10),
        memberIndex = this.indices.indexOf(index);

    if (memberIndex > -1) {
      return this.updateMember(memberIndex, memberParams);
    }
    return this.insertMember(memberParams);
  }
  upsertMembers(membersParams: Array<any>) {
    return membersParams.map((memberParams: any) => this.upsertMember(memberParams));
  }
  upsertMorphs(morphs: Array<any>) {
    return morphs.map((morph: any) => this.upsertMorph(morph));
  }
  upsertMorph(morph: any) {
    this.touchMorph(morph);

    let tween = this.morphs[morph.rule][morph.key].morphs[morph.index];

    if (this.morphIndices.indexOf(morph.index) === -1) {
      this.morphIndices.push(morph.index);
    }
    if (tween) {
      let member = this.getMember(morph.index);

      if (member) {
        member.freezeMorph(morph.key, morph.rule, morph.index);
      }
    };
    this.morphs[morph.rule][morph.key].morphs[morph.index] = morph.tween;

    return {
      key: morph.key,
      index: morph.index,
      ring: this.name,
      rule: morph.rule,
      tween: morph.tween,
      zone: this.zone,
      zoneName: this.zoneName
    };
  }
  updateMember(index: number, params: any) {
    let schemaKeys = Object.keys(this.schema),
        member = this.members[index],
        memberIndex = member.index();

    for (let i = 0, l = schemaKeys.length; i !== l; i++) {
      let key = schemaKeys[i];

      if (params[key]) {
        member.setAttribute(key, Ring.castMemberValue(params[key], this.schema[key]));
      }
    }
    this.refreshIndices();

    return member;
  }
  static castMemberValue(value: any, type: string) : any {
    switch (type) {
      case "Integer":
        return parseInt(value, 10);
      case "Morphs":
        return JSON.parse(value);
      default:
        return value;
    }
  }
  static representMembers(members: Array<RingMember>) {
    let results : Array<any> = [];

    for (let i = 0, l = members.length; i !== l; i++) {
      results.push(Ring.representMember(members[i]));
    }
    return results;
  }
  static representMember(member: RingMember) {
    let result: any = {};

    result = member.attributes
    result.__isNew__ = member.isNew;
    result.__ring__ = member.parent.name;
    result.__zone__ = member.parent.zone;
    result.__zoneName__ = member.parent.zoneName;

    return result;
  }
}
