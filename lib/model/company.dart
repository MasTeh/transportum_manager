enum CompanyType { own, client, service, hujznaet }
enum OrgForm { OOO, IP, none }

class CompanyProps {
  final String inn;
  final String kpp;
  final String orgName;
  final String orgAddress1;
  final String orgAddress2;
  final OrgForm orgForm;

  const CompanyProps(this.inn, this.kpp, this.orgName, this.orgAddress1,
      this.orgAddress2, this.orgForm);
}

class Company {
  final int id;
  final int client_id;
  final String name;
  final String phone;
  final String contactName;
  final String cityName;
  final String contactsText;
  final CompanyType companyType;
  final bool isDefault;
  final CompanyProps props;

  const Company(
      this.id,
      this.client_id,
      this.name,
      this.phone,
      this.contactName,
      this.cityName,
      this.contactsText,
      this.companyType,
      this.isDefault,
      this.props);

  factory Company.fromJSON(Map<String, dynamic> jsonData) {
    OrgForm orgForm;
    CompanyType companyType;
    CompanyProps companyProps;

    String _typeParam = jsonData['type'] as String;
    int _orgTypeParam = jsonData['org_type'] as int;

    if (_typeParam == 'own')
      companyType = CompanyType.own;
    else if (_typeParam == 'client')
      companyType = CompanyType.client;
    else if (_typeParam == 'service')
      companyType = CompanyType.service;
    else
      companyType = CompanyType.hujznaet;

    if (_orgTypeParam == 2)
      orgForm = OrgForm.OOO;
    else if (_orgTypeParam == 1)
      orgForm = OrgForm.IP;
    else
      orgForm = OrgForm.none;

    companyProps = CompanyProps(
        jsonData['org_inn'] as String,
        jsonData['org_kpp'] as String,
        jsonData['org_name'] as String,
        jsonData['org_adr1'] as String,
        jsonData['org_adr2'] as String,
        orgForm);

    int _defaultCompany = jsonData['is_default'] as int;
    bool defaultFlag = false;
    if (_defaultCompany == 1) defaultFlag = true;

    return Company(
        jsonData['id'] as int,
        jsonData['client_id'] as int,
        jsonData['name'] as String,
        jsonData['phone'] as String,
        jsonData['contact_name'] as String,
        jsonData['city'] as String,
        jsonData['contacts'] as String,
        companyType,
        defaultFlag,
        companyProps);
  }
}
