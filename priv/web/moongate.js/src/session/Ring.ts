import { RingMember } from './RingMember';

export class Ring {
  indices: Array<number>
  members: Array<RingMember>
  morphs: any
  name: string
  schema: any
  constructor(name: string, schema: any) {
    this.indices = [];
    this.members = [];
    this.morphs = {};
    this.name = name;
    this.schema = schema
  }
  refreshIndices() {
    let result : Array<number> = [];

    for (let i = 0, l = this.members.length; i !== l; i++) {
      result.push(this.members[i].index());
    }
    this.indices = result;
  }
  destroyMembers(memberIndices: Array<number>) {
    this.members = this.members.filter((member) => {
      return memberIndices.indexOf(member.index()) == -1;
    });
    this.refreshIndices();

    return memberIndices;
  }
  upsertMembers(membersParams: Array<any>) {
    return membersParams.map((memberParams: any) => this.upsertMember(memberParams));
  }
  upsertMember(memberParams: any) : any {
    let index = parseInt(memberParams.__index__, 10),
        memberIndex = this.indices.indexOf(index);

    if (memberIndex > -1) {
      return this.updateMember(memberIndex, memberParams);
    }
    return this.insertMember(memberParams);
  }
  upsertMorphs(morphs: Array<any>) {
    return morphs.map((morph: any) => this.upsertMorph(morph));
  }
  upsertMorph(morph: any) {
    if (!this.morphs[morph.rule]) { this.morphs[morph.rule] = {}}
    if (!this.morphs[morph.rule][morph.key]) {
      this.morphs[morph.rule][morph.key] = {
        morphs: {}
      }
    }
    this.morphs[morph.rule][morph.key].morphs[morph.index] = morph.tween;
  }
  updateMember(memberIndex : number, params : any) {
    let member = this.members[memberIndex];

    Object.keys(this.schema).forEach((key) => {
      if (params[key]) {
        member.setAttribute(key, Ring.castMemberValue(params[key], this.schema[key]));
      }
    })
    this.refreshIndices();
    return member;
  }
  insertMember(params: any) {
    let result : any = {};

    Object.keys(this.schema).forEach((key) => {
      if (params[key]) {
        result[key] = Ring.castMemberValue(params[key], this.schema[key]);
      }
    })
    let member = new RingMember(result, this);
    this.members.push(member);
    this.refreshIndices();
    return member;
  }
  static castMemberValue(value: any, type: string) : any {
    switch (type) {
      case 'Integer':
        return parseInt(value, 10);
      case 'Morphs':
        return JSON.parse(value);
      default:
        return value;
    }
  }
}
