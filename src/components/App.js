import React, { Component } from 'react';
import { AgGridReact } from 'ag-grid-react';

import '../assets/css/App.css';
import '../assets/aggrid/ag-grid.css';
import '../assets/aggrid/ag-theme-balham.css';
import 'ag-grid-enterprise';

class App extends Component {
    constructor(props) {
        super(props);

        this.state = {
            columnDefs: [],
            rowData: []
        }
    }

    componentDidMount() {
        var sqlite3 = require('sqlite3').verbose();
        let db = new sqlite3.Database('/usr/local/realdb.db');

        db.serialize(() => {
            db.all(`select PARID, 
                    PROPERTYHOUSENUM,
                    PROPERTYFRACTION,
                    PROPERTYADDRESS,
                    PROPERTYCITY,
                    PROPERTYSTATE,
                    PROPERTYUNIT,
                    PROPERTYZIP,
                    WARD,
                    BLOCK_LOT,
                    \`filing_date:1\`,
                    case_id,
                    docket_type,
                    \`amount:1\`,
                    plaintiff,
                    FILING_DATE,
                    DTD,
                    LIEN_DESCRIPTION,
                    LAST_DOCKET_ENTRY,
                    AMOUNT,
                    TAX_YEAR,
                    SATISFIED,
                    INSPECTION_DATE,
                    INSPECTION_RESULT,
                    VIOLATION,
                    LOCATION,
                    NEIGHBORHOOD,
                    OWNERDESC,
                    CLASSDESC,
                    USEDESC,
                    SALEDATE,
                    SALEPRICE,
                    SALEDESC,
                    PREVSALEDATE,
                    PREVSALEPRICE,
                    STORIES,
                    YEARBLT,
                    EXTFINISH_DESC,
                    GRADEDESC,
                    TOTALROOMS,
                    BEDROOMS,
                    FULLBATHS,
                    HALFBATHS,
                    FINISHEDLIVINGAREA
                    from composed`, (err, rowData) => {
                let columnDefs = [];
                Object.getOwnPropertyNames(rowData[0]).map((value) => {
                    if(value.toLowerCase().endsWith('date') ){
                        columnDefs.push({headerName: value, field: value, filter: "agDateColumnFilter"});
                    } else if(value.endsWith('PRICE') || value.endsWith('AMOUNT')){
                        columnDefs.push({headerName: value, 
                            field: value, 
                            filter: "agNumberColumnFilter", 
                            cellClass: 'dollar',
                            valueFormatter: function (params) {
                                let val = params.value.split('.');
                                let comma = Number(parseInt(val[0]).toFixed(1)).toLocaleString();
                                let dec = val[1];
                                if(dec){
                                    return comma + '.' + dec;
                                } else {
                                    return comma + '.00';
                                }
                            },
                            comparator: function (valueA, valueB, nodeA, nodeB, isInverted) {
                                return valueA - valueB;
                            }
                        });
                    } 
                    else {
                        columnDefs.push({headerName: value, field: value});
                    }
                    
                })
                this.setState({rowData, columnDefs});
            });
        });
        db.close();
    }

    render() {
        const {rowData} = this.state;
        return (
            <div
                className="ag-theme-balham"
                style={{
                    height: '768px',
                    width: '99%',
                    margin: 'auto'
                }}
            >
            <AgGridReact
                enableSorting={true}
                enableFilter={true}
                enableColResize={true}
                columnDefs={this.state.columnDefs}
                rowData={this.state.rowData}>
            </AgGridReact>
            </div>
        );
    }
}

export default App;
