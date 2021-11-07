library json_to_form;

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:wolf_jobs/UI/AdditionalDataForm/uploadFile.dart';
import 'package:wolf_jobs/UI/AdditionalDataForm/uploadFileCustom.dart';

class JsonToForm extends StatefulWidget {
  const JsonToForm({
    @required this.form,
    @required this.onChanged,
    this.padding,
    this.formMap,
    this.errorMessages = const {},
    this.validations = const {},
    this.decorations = const {},
    this.buttonSave,
    this.actionSave,
  });

  final Map errorMessages;
  final Map validations;
  final Map decorations;
  final String form;
  final Map formMap;
  final double padding;
  final Widget buttonSave;
  final Function actionSave;
  final ValueChanged<dynamic> onChanged;

  @override
  _CoreFormState createState() =>
      new _CoreFormState(formMap ?? json.decode(form));
}

class _CoreFormState extends State<JsonToForm> {
  final dynamic formGeneral;

  int radioValue;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();                     
  }
  // validators

  String isRequired(item, value) {
    if (value.isEmpty) {
      return widget.errorMessages[item['key']] ?? 'Please enter some text';
    }
    return null;
  }

  bool _isNumeric(String str) {
    if(str == null) {
      return false;
    }
    return double.tryParse(str) != null;
  }

  String validateEmail(item, String value) {
    String p = "[a-zA-Z0-9\+\.\_\%\-\+]{1,256}" +
        "\\@" +
        "[a-zA-Z0-9][a-zA-Z0-9\\-]{0,64}" +
        "(" +
        "\\." +
        "[a-zA-Z0-9][a-zA-Z0-9\\-]{0,25}" +
        ")+";
    RegExp regExp = new RegExp(p);

    if (regExp.hasMatch(value)) {
      return null;
    }
    return 'Email is not valid';
  }

  bool labelHidden(item) {
    if (item.containsKey('hiddenLabel')) {
      if (item['hiddenLabel'] is bool) {
        return !item['hiddenLabel'];
      }
    } else {
      return true;
    }
    return false;
  }

  // Return widgets

  List<Widget> jsonToForm() {
    List<Widget> listWidget = new List<Widget>();
    if (formGeneral['form_title'] != null) {      
      listWidget.add(Container(
        margin: EdgeInsets.symmetric(horizontal: 10.0),
        padding: EdgeInsets.only(bottom: formGeneral['form_description'] != null ? 0.0 : 10.0),
        child: Text(
          formGeneral['form_title'],
          style: new TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0),
        ),
      ));
    }
    if (formGeneral['form_description'] != null) {
      listWidget.add(Container(
        margin: EdgeInsets.symmetric(horizontal: 10.0),
        padding: EdgeInsets.only(bottom: 10.0),
        child: Text(
          formGeneral['form_description'],
          style: new TextStyle(fontSize: 14.0,fontStyle: FontStyle.italic),
        ),
      ));
    }

    for (var count = 0; count < formGeneral['fields'].length; count++) {
      Map item = formGeneral['fields'][count];

      if (item['type'] == "Input" ||
          item['type'] == "Password" ||
          item['type'] == "Email" ||
          item['type'] == "TextArea" ||
          item['type'] == "TextInput" || 
          item['type'] == "Integer") {        
        listWidget.add(new Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[            
            Padding(
              padding: const EdgeInsets.only(
                  top: 10.0, bottom: 0,  left: 30.0, right: 30.0),
              /* child: Divider(
                color: Colors.black12,
                height: 2.0,
              ), */
              ),
            Padding(
              padding: const EdgeInsets.only(top: 5.0, left: 15.0, right: 15.0, bottom: 10),
              child: Text(item['label']),
            ),
            Container(                                                      
              /* decoration: BoxDecoration(border: Border.all(width: 2.0, color: Colors.red)), */
              padding: EdgeInsets.only(top: 0.0),                
              child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10.0),
                  child: Container(                                                
                    height: 60.0,
                    alignment: AlignmentDirectional.center,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14.0),
                        color: Colors.white,
                        boxShadow: [BoxShadow(blurRadius: 10.0, color: Colors.black12)]),
                    padding:
                    EdgeInsets.only(left: 20.0, right: 30.0, top: 0.0, bottom: 0.0),
                    child: Theme(
                      data: ThemeData(
                        hintColor: Colors.transparent,
                      ),
                      child: TextFormField(                                                  
                        initialValue: formGeneral['fields'][count]['value']??null,                                                                                                                             
                        decoration: InputDecoration(                              
                            errorStyle: TextStyle(
                              fontSize: 10.0,                              
                            ),
                            /* border: InputBorder.none, */
                            border: InputBorder.none, 
                            labelText:  item['placeholder'],
                            labelStyle: TextStyle(
                                fontSize: 15.0,
                                fontFamily: 'Sans',
                                letterSpacing: 0.3,
                                color: Colors.black38,
                                fontWeight: FontWeight.w600)),

                        validator: (value) {
                          if (widget.validations.containsKey(item['key'])) {
                            return widget.validations[item['key']](item, value);
                          }
                          if (item.containsKey('validator')) {
                            if (item['validator'] != null) {
                              if (item['validator'] is Function) {
                                return item['validator'](item, value);
                              }
                            }
                          }
                          if (item['type'] == "Email") {
                            return validateEmail(item, value);
                          }
                          if (item['type'] == "Integer") {                            
                            if (formGeneral['fields'][count]['value'] != null) {                              
                              if (int.tryParse(formGeneral['fields'][count]['value']) != null) {
                                return null;
                              } else {
                                return 'The value has to be an integer';
                              }
                            }
                                                    
                          } 
                          if (item.containsKey('required')) {
                            if (item['required'] == true ||
                                item['required'] == 'True' ||
                                item['required'] == 'true') {
                              return isRequired(item, value);
                            }
                          }

                          return null;
                        },                                  
                        onChanged: (String value) {
                          formGeneral['fields'][count]['value'] = value;                          
                          _handleChanged();
                        },                       
                        onSaved: (String value) {   
                          /* listFreeText[ models[position].custom_requirement_id.toString()] = value;      */                                                   
                        /*  _formData['value'] = value;                            
                          await updateFreeText(
                            models[position].custom_requirement_id.toString()
                          ); */
                          /* if (models[position] == (models.length-1)) {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => HomePage()),
                                );  
                            }  */                           
                        },                            
                      ),
                    ),
                  ),
                ),
            )
          ],
        ));
      }

      if (item['type'] == "RadioButton") {
        List<Widget> radios = [];

        if (labelHidden(item)) {
          radios.add(new Text(item['label'],
              style:
                  new TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0)));
        }
        radioValue = item['value'];
        for (var i = 0; i < item['items'].length; i++) {
          radios.add(
            new Row(
              children: <Widget>[
                new Expanded(
                    child: new Text(
                        formGeneral['fields'][count]['items'][i]['label'])),
                new Radio<int>(
                    value: formGeneral['fields'][count]['items'][i]['value'],
                    groupValue: radioValue,
                    onChanged: (int value) {
                      this.setState(() {
                        radioValue = value;
                        formGeneral['fields'][count]['value'] = value;
                        _handleChanged();
                      });
                    })
              ],
            ),
          );
        }

        listWidget.add(
          new Container(
            margin: new EdgeInsets.only(top: 5.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: radios,
            ),
          ),
        );
      }

      if (item['type'] == "Switch") {
        if (item['value'] == null) {
          formGeneral['fields'][count]['value'] = false;
        }
        listWidget.add(
          new Container(
            margin: new EdgeInsets.only(top: 5.0),
            child: new Row(children: <Widget>[
              new Expanded(child: new Text(item['label'])),
              new Switch(
                value: item['value'] ?? false,
                onChanged: (bool value) {
                  this.setState(() {
                    formGeneral['fields'][count]['value'] = value;
                    _handleChanged();
                  });
                },
              ),
            ]),
          ),
        );
      }

      if (item['type'] == "Checkbox") {
        List<Widget> checkboxes = [];        
        if (labelHidden(item)) {
          checkboxes.add(Container(
            margin: EdgeInsets.only(right: 15.0, left: 15.0, top: 15.0),
            child: new Text(item['label'],
                style:
                    new TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0)),
          ));
        }
       for (var i = 0; i < item['items'].length; i++) {          
          checkboxes.add(
            Container(
              margin: EdgeInsets.symmetric(horizontal: 5.0),
              child: new Row(
                children: <Widget>[                  
                  new Checkbox(
                    value: formGeneral['fields'][count]['items'][i]['value'],
                    onChanged: (bool value) {
                      this.setState(
                        () {
                          formGeneral['fields'][count]['items'][i]['value'] =
                              value;
                          _handleChanged();
                        },
                      );
                    },
                  ),
                  new Expanded(
                    child: new Text(
                        formGeneral['fields'][count]['items'][i]['label'])),
                ],
              ),
            ),
          );
        }                          
        listWidget.add(
          new Container(
            margin: new EdgeInsets.only(top: 5.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: checkboxes,
            ),
          ),
        );
      }

      if (item['type'] == "Select") {
        /* Widget label = SizedBox.shrink();
        if (labelHidden(item)) {
          label = new Text(item['label'],
              style:
                  new TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0));
        }  */               
        listWidget.add(new Container(
          margin: new EdgeInsets.only(top: 5.0),
          child: Column(        
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,          
            children: <Widget>[                            
              Padding(
                padding: const EdgeInsets.only(
                    top: 10.0, bottom: 0, left: 30.0, right: 30.0),
              ),
              Padding(
                  padding: const EdgeInsets.only(top: 5.0, left: 15.0, right: 15.0, bottom: 10),
                  child: Text(item['label']),
                ),
              Container(                    
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14.0),                        
                    color: Colors.white,                        
                    boxShadow: [
                      BoxShadow(blurRadius: 10.0, color: Colors.black12)
                    ]),
                margin: EdgeInsets.only(left: 10.0, right: 10.0, bottom: 0.0),
                  alignment: AlignmentDirectional.center,
                  height: 60.0,

                  padding: EdgeInsets.only(left: 0.0, right: 10.0, top: 0.0, bottom: 0.0),

                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      padding: EdgeInsets.only(left: 20),
                      width: MediaQuery.of(context).size.width*0.75,                     
                      child: DropdownButtonFormField<String>(      
                          hint: Text(formGeneral['fields'][count]['placeholder']),                      
                          icon: Icon(Icons.keyboard_arrow_down , size: 12, color: Colors.black,),                           
                          isDense: true,
                          isExpanded: true,
                          style: TextStyle(fontSize: 16, fontFamily: 'Sans'),
                          decoration: InputDecoration(
                            isDense: true,
                            contentPadding: EdgeInsets.all(0.0),
                            border: InputBorder.none,                                 
                            labelStyle: new TextStyle(                                      
                                fontSize: 15,
                                fontFamily: 'sans',
                                color: Colors.black38,
                                fontWeight: FontWeight.w600),
                            /* labelText: models[position].question, */
                          ),
                          items: item['items'].map<DropdownMenuItem<String>>((dynamic data) {
                            return new DropdownMenuItem<String>(                                
                              value: data['value'],
                              child: FittedBox(
                                fit: BoxFit.contain,
                                child: Row(
                                  children: <Widget>[
                                    Text(
                                      data['label'],
                                      style: TextStyle(
                                        color: Colors.black,  
                                        fontSize: 14.0                                            
                                      ),
                                    )
                                  ],
                                )
                                ),
                            );
                          }).toList(),
                          value: formGeneral['fields'][count]['value'],                         
                          onChanged: (String newValue) {
                             setState(() {
                              formGeneral['fields'][count]['value'] = newValue;
                              _handleChanged();
                            });
                          },                          
                        ),
                    ),
                  ],
                )
                )              
            ],
          ),
        ));
        /* listWidget.add(new Container(
          margin: new EdgeInsets.only(top: 5.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              label,
              new DropdownButton<String>(
                hint: Text(formGeneral['fields'][count]['placeholder']),
                value: formGeneral['fields'][count]['value'],
                onChanged: (String newValue) {
                  setState(() {
                    formGeneral['fields'][count]['value'] = newValue;
                    _handleChanged();
                  });
                },
                items:
                    item['items'].map<DropdownMenuItem<String>>((dynamic data) {                      
                  return DropdownMenuItem<String>(
                    value: data['value'],
                    child: new Text(
                      data['label'],
                      style: new TextStyle(color: Colors.black),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ) */
      }

      if (item['type'] == "File") {                      
        listWidget.add(new Column(
          children: <Widget>[                  
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(
                      top: 0.0, left: 30.0, right: 30.0, bottom:10),                  
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 5.0, left: 15.0, right: 15.0, bottom: 10),
                  child: Text(item['label']),
                ),
                CustomFormUploadButton(key: UniqueKey(), custom_requirement_id: item['key'].toString(),),
              ],
            )
          ],
        ));
      }
    }

    if (widget.buttonSave != null) {
      listWidget.add(new Container(
        margin: EdgeInsets.only(top: 15.0, left: 10.0, right: 10.0),
        child: InkWell(
          onTap: () {
            if (_formKey.currentState.validate()) {
              widget.actionSave(formGeneral);
            }
          },
          child: widget.buttonSave,
        ),
      ));
    }
    return listWidget;
  }

  _CoreFormState(this.formGeneral);

  void _handleChanged() {
    widget.onChanged(formGeneral);
  }

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Form(
      autovalidate: formGeneral['autoValidated'] ?? false,
      key: _formKey,
      child: new Container(
        padding: new EdgeInsets.all(widget.padding ?? 8.0),
        child: new Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: jsonToForm(),
        ),
      ),
    );
  }
}
