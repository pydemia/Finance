

import xml
from xml.etree import ElementTree
import csv
import json
import numpy as np
import pandas as pd
import unipy_db as udb

import io
import zipfile
import urllib
import requests


QUANDL_API_KEY = 'sa2FLifFfoePCxGcknS-'

# %% `PROVIDER_MAS` ----------------------------------------------------------

TABLE_NM = 'PROVIDER_MAS'

get_column_str = f"""
SHOW columns FROM `finance_db`.`{TABLE_NM}`
;
"""

col_df = udb.from_mysql(
    get_column_str,
    h='35.188.205.252', port=3306, db='finance_db', u='mas', p='mas'
)

prv_new_row_list = [
    [None, 'GOOGLE', 'google finance api'],
    [None, 'YAHOO', 'yahoo finance api'],
    [None, 'QUANDL', 'quandl data api'],
]
prv_new_rows = pd.DataFrame(prv_new_row_list, columns=col_df['Field'].values)

udb.insert_mysql(
    prv_new_rows, h='35.188.205.252', port=3306, u='mas', p='mas',
    db='finance_db', table=TABLE_NM, logging=False,
)

# %% `REGION_MAS` ------------------------------------------------------------

TABLE_NM = 'REGION_MAS'
get_column_str = f"""
SHOW columns FROM `finance_db`.`{TABLE_NM}`
;
"""

col_df = udb.from_mysql(
    get_column_str,
    h='35.188.205.252', port=3306, db='finance_db', u='mas', p='mas'
)

regional_code_url = 'https://raw.githubusercontent.com/pydemia/ISO-3166-Countries-with-Regional-Codes/master/all/all.json'
with urllib.request.urlopen(regional_code_url) as resp:
    jfile = json.loads(resp.read().decode())
    reg_ctry_code_df = pd.DataFrame.from_records(jfile)

reg_ctry_code_df = reg_ctry_code_df.loc[reg_ctry_code_df['name'] != 'Antarctica']

reg_code_df = reg_ctry_code_df[
    [
        'region-code', 'sub-region-code',
        'region', 'sub-region',
    ]
].drop_duplicates(subset=['region-code', 'sub-region-code'])

reg_code_df['desc'] = None

# new_row_list = [
#     ['WORLD', 'Worldwide'],
#     ['ASIA', 'Asia'],
#     ['N_AMERICA', 'North America'],
#     ['EUROPE', 'Europe'],
#     ['S_AMERICA', 'South America'],
#     ['AFRICA', 'Africa'],
#     ['OCEANIA', 'Oceania'],
#     ['ANTARCTICA', 'Antarctica'],
# ]
reg_new_rows = pd.DataFrame(reg_code_df.values, columns=col_df['Field'].values)
reg_new_rows.loc[0, :]
world_reg_list = [
    ['000', '000', 'Worldwide', 'Worldwide', None],
    ['999', '999', 'Europe', 'Europewide', None],
]

world_reg_row = pd.DataFrame(world_reg_list, columns=col_df['Field'].values)
reg_final_rows = world_reg_row.append(reg_new_rows)

udb.insert_mysql(
    reg_final_rows, h='35.188.205.252', port=3306, u='mas', p='mas',
    db='finance_db', table=TABLE_NM, logging=False,
)

# %% `CURRENCY_MAS` ------------------------------------------------------------

TABLE_NM = 'CURRENCY_MAS'
get_column_str = f"""
SHOW columns FROM `finance_db`.`{TABLE_NM}`
;
"""

col_df = udb.from_mysql(
    get_column_str,
    h='35.188.205.252', port=3306, db='finance_db', u='mas', p='mas'
)

currency_xml_url = 'https://www.currency-iso.org/dam/downloads/lists/list_one.xml'
with urllib.request.urlopen(currency_xml_url) as resp:
    currency_xml = resp.read()


currency_xml
etree_root = ElementTree.fromstring(currency_xml)[0]


def currency_xml_to_dict(etree_item, to_list=False):
    if to_list:
        return {item.tag: [item.text] for item in etree_item}
    else:
        return {item.tag: item.text for item in etree_item}


currency_tbl = pd.DataFrame.from_dict(
    [currency_xml_to_dict(item) for item in etree_root]
)

currency_tbl.columns = ['Code', 'Decimal Place', 'Number', 'Name', 'Country']
currency_tbl = currency_tbl.dropna(subset=['Code'])
currency_tbl.loc[currency_tbl['Decimal Place'] == 'N.A.', ['Decimal Place']] = 0

currency_tbl = currency_tbl[['Code', 'Number', 'Name', 'Decimal Place', 'Country']]
currency_rows = currency_tbl[currency_tbl.columns.drop('Country')].drop_duplicates()
currency_rows.columns = col_df['Field'].values

udb.insert_mysql(
    currency_rows, h='35.188.205.252', port=3306, u='mas', p='mas',
    db='finance_db', table=TABLE_NM, logging=False,
)

# %% `COUNTRY_MAS` ------------------------------------------------------------

TABLE_NM = 'COUNTRY_MAS'
get_column_str = f"""
SHOW columns FROM `finance_db`.`{TABLE_NM}`
;
"""

col_df = udb.from_mysql(
    get_column_str,
    h='35.188.205.252', port=3306, db='finance_db', u='mas', p='mas'
)

reg_ctry_code_df
reg_ctry_code_df.columns


ctry_code_df = reg_ctry_code_df.drop_duplicates(subset=(['name', 'country-code']))
ctry_code_df['name'] = ctry_code_df['name'].str.upper()
ctry_code_df['name'] = ctry_code_df['name'].str.replace(r' [\(\[]', ', ').str.replace(r'[\)\]]', '')

cur_ctry_tbl = currency_tbl[['Code', 'Number', 'Name', 'Country']]
cur_ctry_tbl['Country'] = cur_ctry_tbl['Country'].str.upper()
cur_ctry_tbl['Country'] = cur_ctry_tbl['Country'].str.replace(' \(THE\)', '')
cur_ctry_tbl['Country'] = cur_ctry_tbl['Country'].str.replace(' \(THE ', ' (')
cur_ctry_tbl['Country'] = cur_ctry_tbl['Country'].str.replace(r' [\(\[]', ', ').str.replace(r'[\)\]]', '')

tmp = ctry_code_df.set_index('name').join(
    cur_ctry_tbl[['Country', 'Code', 'Number']].set_index('Country'), how='left'
).reset_index().dropna(how='all')
ttmp = tmp[tmp['Code'].isna()]
tttmp = ttmp[['index', 'country-code']].set_index('country-code', drop=False).join(
    cur_ctry_tbl[['Code', 'Number']].set_index('Number', drop=False)
)

merged = pd.merge(tmp, tttmp, on=['index', 'country-code'], how='left')
merged['Code'] = np.where(merged['Code_x'].notnull(), merged['Code_x'], merged['Code_y'])
merged['Number'] = np.where(merged['Number_x'].notnull(), merged['Number_x'], merged['Number_y'])
merged['desc'] = None
ctry_df = merged[
    [
        'region-code', 'sub-region-code', 'Code',
        'alpha-2', 'country-code', 'alpha-3',
        'index', 'desc',
        'intermediate-region-code', 'intermediate-region',
    ]
].dropna(subset=['Code'])
ctry_df[ctry_df['Code'].isnull()]
ctry_df.isnull().sum()
ctry_df[ctry_df['region-code'].isnull()]
ctry_new_rows = pd.DataFrame(ctry_df.values, columns=col_df['Field'].values)

world_ctry_row_list = [
    ['000', '000', 'USD', 'WW', '000', 'WWD', 'WORLDWIDE', None, '', ''],
    ['999', '999', 'EUR', 'EU', '999', 'EUR', 'EUROPEAN UNION', None, '', ''],
]
world_ctry_row = pd.DataFrame(world_ctry_row_list, columns=ctry_new_rows.columns)
ctry_final_rows = world_ctry_row.append(ctry_new_rows)

udb.insert_mysql(
    ctry_final_rows, h='35.188.205.252', port=3306, u='mas', p='mas',
    db='finance_db', table=TABLE_NM, logging=False,
)

# %% `EXCHANGE_MAS` ----------------------------------------------------------

TABLE_NM = 'EXCHANGE_MAS'
get_column_str = f"""
SHOW columns FROM `finance_db`.`{TABLE_NM}`
;
"""

col_df = udb.from_mysql(
    get_column_str,
    h='35.188.205.252', port=3306, db='finance_db', u='mas', p='mas'
)

exc_csv_url = 'https://www.iso20022.org/sites/default/files/ISO10383_MIC/ISO10383_MIC.csv'
with urllib.request.urlopen(exc_csv_url) as resp:
    exc_csv = resp.read().decode('windows-1252')
    exc_ctry_df = pd.read_csv(io.StringIO(exc_csv))

quandl_csv_url = 'https://raw.githubusercontent.com/pydemia/Finance/master/mas/quandl_commodity_markets.csv'
with urllib.request.urlopen(quandl_csv_url) as resp:
    aa_csv = resp.read().decode('windows-1252')
    quandl_market_df = pd.read_csv(io.StringIO(aa_csv))
quandl_market_df.columns = ['ACRONYM', 'NAME-INSTITUTION DESCRIPTION', 'COMMENTS']

world_exc_list = [
    ['WORLDWIDE', 'WW', 'WODA', 'WODA', 'O', 'ODA', 'WORLDWIDE', None, None, 'ACTIVE', None],
    ['WORLDWIDE', 'WW', 'WWJM', 'WWJM', 'O', 'JOHNMATT', 'LONDON', None, None, 'ACTIVE', None],
    ['WORLDWIDE', 'WW', 'OPEC', 'OPEC', 'O', 'OPEC', 'WORLDWIDE', None, None, 'ACTIVE', None],
    ['WORLDWIDE', 'WW', 'WDBK', 'WDBK', 'O', 'WORLDBANK', 'WORLDWIDE', None, None, 'ACTIVE', None],
    ['WORLDWIDE', 'WW', 'WWGC', 'WWGC', 'O', 'WGC', 'WORLDWIDE', None, None, 'ACTIVE', None],
    ['EUROPEAN UNION', 'EU', 'WWEU', 'WWEU', 'O', 'EU', 'EUROPE', None, None, 'ACTIVE', None],
    ['UNITED STATES OF AMERICA', 'US', 'FRED', 'FRED', 'O', 'FRED', 'ST. LOUIS', None, None, 'ACTIVE', None],
    ['UNITED STATES OF AMERICA', 'US', 'UDOE', 'UDOE', 'O', 'DOE', 'Washington, D.C.', None, None, 'ACTIVE', None],
]
extra_cols = ['NAME-INSTITUTION DESCRIPTION', 'COMMENTS']
exc_ctry_df.columns.drop(extra_cols)
world_exc_df = pd.DataFrame(world_exc_list, columns=exc_ctry_df.columns.drop(extra_cols))
world_ctry_df = pd.merge(world_exc_df, quandl_market_df, on=['ACRONYM'])
exc_ctry_extra_df = world_ctry_df[exc_ctry_df.columns]
exc_ctry_final_df = exc_ctry_extra_df.append(exc_ctry_df)
exc_ctry_final_df['NAME-INSTITUTION DESCRIPTION'] = (
    exc_ctry_final_df['NAME-INSTITUTION DESCRIPTION'].str.upper()
)

exc_tmp = (
    exc_ctry_final_df.set_index('ISO COUNTRY CODE (ISO 3166)')
    .join(ctry_final_rows.set_index('CTRY_CD'), how='inner')
    .reset_index()
)
exc_tmp['OPEN_TIME'] = None
exc_tmp['CLOSE_TIME'] = None
exc_df = exc_tmp[
    [
        'RGN_CD', 'SUB_RGN_CD', 'CUR_CD', 'index', 'CTRY_NB', 'CTRY_CD3',
        'MIC', 'NAME-INSTITUTION DESCRIPTION', 'OPERATING MIC',
        'ACRONYM', 'OPEN_TIME', 'CLOSE_TIME',
        'CITY', 'COMMENTS', 'WEBSITE',
    ]
]
exc_new_rows = pd.DataFrame(exc_df.values, columns=col_df['Field'].values)
exc_new_rows = exc_new_rows[exc_new_rows['CUR_CD'] != 'USN']

udb.insert_mysql(
    exc_new_rows, h='35.188.205.252', port=3306, u='mas', p='mas',
    db='finance_db', table=TABLE_NM, logging=False,
)

# %% `CLASS_MAS` -------------------------------------------------------------

TABLE_NM = 'CLASS_MAS'

get_column_str = f"""
SHOW columns FROM `finance_db`.`{TABLE_NM}`
;
"""

col_df = udb.from_mysql(
    get_column_str,
    h='35.188.205.252', port=3306, db='finance_db', u='mas', p='mas'
)

new_row_list = [
    ['EQT', 'Equity', 'Price'],
    ['CMT', 'Commodity', 'Price'],
    ['ITR', 'Interest Rate', 'Ratio'],
    ['BND', 'Bond', 'Price'],
    ['OPT', 'Option', 'Price'],
    ['FTR', 'Future', 'Price'],
    ['SWP', 'SWAP', 'Price'],
    ['IDX', 'Index', 'Metrics'],
    ['FND', 'Fund', 'Price'],
    ['RES', 'Real Estate', 'Price'],
    ['STX', 'Stock Index', 'Metrics'],
    ['ECX', 'Economical Index', 'Metrics'],
    ['STT', 'Statistics', 'Metrics'],
    ['FRX', 'Foreign Exchange', 'Price'],
]

cls_new_rows = pd.DataFrame(new_row_list, columns=col_df['Field'].values)

udb.insert_mysql(
    cls_new_rows, h='35.188.205.252', port=3306, u='mas', p='mas',
    db='finance_db', table=TABLE_NM, logging=False,
)


# %% `ITEM_MAS` --------------------------------------------------------------


TABLE_NM = 'ITEM_MAS'

get_column_str = f"""
SHOW columns FROM `finance_db`.`{TABLE_NM}`
;
"""

col_df = udb.from_mysql(
    get_column_str,
    h='35.188.205.252', port=3306, db='finance_db', u='mas', p='mas'
)
col_df

prv_new_rows
cls_new_rows

# SYMBOL: Yahoo - STOCKINDEX

exc_new_rows.columns
exc_unique = exc_new_rows[
    ['CTRY_CD', 'EXG_CD', 'EXG_NM', 'EXG_OP_CD', 'EXG_ACRONYM', 'EXG_CITY', 'EXG_DESC']
].drop_duplicates()

# exc_unique[exc_unique['CTRY_CD'] == 'BR']
# exc_unique[['EXG_NM', 'EXG_ACRONYM', 'EXG_DESC']].apply(lambda x: x.str.contains('NY')).any(axis=1)
# exc_unique[
#     (exc_unique['CTRY_CD'] == 'BR') &
#     exc_unique[['EXG_NM', 'EXG_ACRONYM', 'EXG_OP_CD', 'EXG_DESC']].apply(lambda x: x.str.contains('BOLSA DE')).any(axis=1)
# ]

yahoo_stockindex_df = pd.DataFrame(
    [
        ['Y', 'KR', 'XKRX', 'KOSPI Composite Index', '^KS11'],
        ['Y', 'KR', 'XKOS', 'Kosdaq Composite Index', '^KQ11'],
        ['Y', 'US', 'XNYS', 'NYSE Composite', '^NYA'],
        ['Y', 'US', 'XNAS', 'NASDAQ Composite', '^IXIC'],
        ['Y', 'US', 'XNAS', 'NASDAQ 100 Composite', '^NDX'],
        ['Y', 'US', 'XNYS', 'Dow Jones Industrial Average', '^DJI'],
        ['Y', 'US', 'XNYS', 'S&P 500', '^GSPC'],
        ['Y', 'US', 'XNYS', 'RUSSELL 2000', '^RUT'],
        ['Y', 'JP', 'XTKS', 'NIKKEI 225', '^N225'],
        ['Y', 'CN', 'XSHE', 'Shenzhen Component Index', '399001.SZ'],
        ['Y', 'CN', 'XSHG', 'SSE Composite Index', '000001.SS'],
        ['Y', 'CN', 'XSSC', 'HANGSENG Index', '^HSI'],
        ['Y', 'EU', 'WWEU', 'EURO Stoxx 50 (ESTX 50 PR.EUR)', '^STOXX50E'],
        ['Y', 'EU', 'XLIS', 'EURONEXT 100', '^N100'],
        ['Y', 'DE', 'FRAB', 'DAX Performance-Index', '^GDAXI'],
        ['Y', 'GB', 'XLON', 'FTSE 100', '^FTSE'],
        ['Y', 'FR', 'XPAR', 'CAC 40', '^FCHI'],
        ['Y', 'BE', 'XBRU', 'BEL 20', '^BFX'],
        ['Y', 'NL', 'XAMS', 'AEX', '^AEX'],
        ['Y', 'ES', 'XMAD', 'IBEX 35', '^IBEX'],
        ['Y', 'RU', 'XMOS', 'MICEX', 'MICEXINDEXCF.ME'],
        ['Y', 'TW', 'XTAI', 'TSEC Weighted Index', '^TWII'],
        ['Y', 'SG', 'XSES', 'Straits Times Index', '^STI'],
        ['Y', 'IN', 'BVMF', 'BSE SENSEX', '^BSESN'],
        ['Y', 'BR', 'BVMF', 'IBOVESPA', '^BVSP'],
    ],
    columns=['USE_YN', 'CTRY_CD', 'EXG_CD', 'ITEM_NM', 'ITEM_CD'],
)
yahoo_stockindex_df['PRV_NM'] = 'YAHOO'
yahoo_stockindex_df['CLS_CD'] = 'STX'
yahoo_stockindex_df['STX_NM'] = yahoo_stockindex_df['ITEM_NM']
stockindex_df = yahoo_stockindex_df[
    ['CLS_CD', 'PRV_NM', 'CTRY_CD', 'EXG_CD', 'ITEM_NM', 'ITEM_CD', 'USE_YN', 'STX_NM']
]


# SYMBOL: Quandl - FX
quandl_fx_url = 'https://raw.githubusercontent.com/pydemia/Finance/master/mas/quandl_currency_fx_usd.csv'
with urllib.request.urlopen(quandl_fx_url) as resp:
    quandl_fx_mas_df = pd.read_csv(io.StringIO(resp.read().decode('windows-1252')))

quandl_fx_mas_df
quandl_fx_mas_df['CUR_CD'] = quandl_fx_mas_df['Currency'].str.replace('.*\(', '').str.replace('\)', '')
quandl_fx_mas_df['ITEM_CD'] = quandl_fx_mas_df['Code'].apply(lambda x: 'FRED/' + x)
quandl_fx_mas_df['ITEM_NM'] = quandl_fx_mas_df['CUR_CD']
quandl_fx_mas_df['FX_BASE'] = 'USD'
quandl_fx_mas_df['PRV_NM'] = 'QUANDL'
quandl_fx_mas_df['USE_YN'] = 'Y'
quandl_fx_mas_df = quandl_fx_mas_df[
    ['CUR_CD', 'ITEM_CD', 'FX_BASE', 'ITEM_NM', 'PRV_NM', 'USE_YN']
]


# SYMBOL: Yahoo - FX
yahoo_fx_mas_df = quandl_fx_mas_df.copy()
yahoo_fx_mas_df['ITEM_CD'] = yahoo_fx_mas_df['CUR_CD'].apply(lambda x: x + '=X')
yahoo_fx_mas_df['PRV_NM'] = 'YAHOO'
yahoo_fx_mas_df['FX_BASE'] = 'USD'
yahoo_fx_mas_df['USE_YN'] = 'N'
yahoo_fx_mas_df = yahoo_fx_mas_df[
    ['CUR_CD', 'ITEM_CD', 'FX_BASE', 'ITEM_NM', 'PRV_NM', 'USE_YN']
]
fx_mas_df = pd.concat(
    [quandl_fx_mas_df, yahoo_fx_mas_df],
    ignore_index=True,
    sort=True,
)
fx_mas_df['CLS_CD'] = 'FRX'


# SYMBOL: Quandl - Gov. Bond Yield Curve
cc = ['KOR', 'USA', 'JPN', 'CHN', 'DEU']
ccc = ['KR', 'US', 'JP', 'CN', 'DE']
quandl_gbd_yc_list = [[ca, cb, 'YC/' + ca] for ca, cb in zip(cc, ccc)]
quandl_gbd_yc_list
ctry_cd = 'KR'
def get_maturity_fn(ctry_cd):
    m_list = udb.from_mysql(
        f"""
        SHOW COLUMNS FROM `finance_db`.`GOVBOND_YIELD_{ctry_cd}_RAW`;
        """,
        h='35.188.205.252', port=3306, db='finance_db', u='mas', p='mas'
    )['Field'][1:].values

    m_df = pd.DataFrame(m_list, columns=['MATURITY'])
    m_df['CTRY_CD'] = ctry_cd

    return m_df[['CTRY_CD', 'MATURITY']]
tmp = get_maturity_fn(ctry_cd)
y_df_list = [get_maturity_fn(ca) for ca in ccc]
quandl_gbd_yc_df = pd.concat(
    y_df_list,
    ignore_index=True,
    sort=True,
)

ctry_code_subset = ctry_new_rows[['CTRY_CD', 'CTRY_CD3']].drop_duplicates()
ctry_code_subset['PRV_NM'] = 'QUANDL'
ctry_code_subset['ITEM_CD'] = 'YC/' + ctry_code_subset['CTRY_CD3']
quandl_gbd_yc_mas_df = pd.merge(
    ctry_code_subset, quandl_gbd_yc_df,
    on=['CTRY_CD'], how='inner',
)
quandl_gbd_yc_mas_df['USE_YN'] = 'Y'
gbd_yc_mas_df = quandl_gbd_yc_mas_df
gbd_yc_mas_df['CLS_CD'] = 'BND'
gbd_yc_mas_df.columns
gbd_yc_mas_df['GBD_NM'] = (
    'National Security, ' + gbd_yc_mas_df['CTRY_CD3'] + ', ' + gbd_yc_mas_df['MATURITY']
)
gbd_yc_mas_df['ITEM_NM'] = gbd_yc_mas_df['GBD_NM']

# SYMBOL: Quandl - COMMODITY
quandl_cmt_mas_url = 'https://raw.githubusercontent.com/pydemia/Finance/master/mas/'
quandl_cmt_mas_file_list = [
    'quandl_commodity_item_cmtindex.csv',
    'quandl_commodity_item_metal.csv',
    'quandl_commodity_item_oil.csv',
    'quandl_commodity_item_ngas.csv',
    'quandl_commodity_item_coal.csv',
    'quandl_commodity_item_grain.csv',
    # 'quandl_commodity_item_farms_and_fishery.csv',
]
quandl_cmt_mas_url_list = [quandl_cmt_mas_url + item for item in quandl_cmt_mas_file_list]


def get_cmt_csv_fn(url):
    with urllib.request.urlopen(url) as resp:
        res = pd.read_csv(io.StringIO(resp.read().decode('windows-1252')))
    return res


quandl_cmt_df = pd.concat(
    [get_cmt_csv_fn(url) for url in quandl_cmt_mas_url_list],
    ignore_index=True,
    sort=True,
)
quandl_cmt_df.loc[quandl_cmt_df['Source'] == 'LBMA', ['Source']] = 'LBM'
quandl_cmt_df = quandl_cmt_df[
    quandl_cmt_df['Source'].isin(exc_unique['EXG_ACRONYM'])
]
quandl_cmt_df.columns = ['ITEM_CD', 'CMT_NM', 'Source']
# quandl_cmt_df = quandl_cmt_mas_df[
#     quandl_cmt_mas_df['Source'].isin(exc_unique['EXG_ACRONYM'])
# ]

exc_unique[~exc_unique['EXG_CD'].isin(['CMEC', 'CMEE'])]
exc_unique_one_cme = exc_unique.loc[
    ~exc_unique['EXG_CD'].isin(['CMEC', 'CMEE']), ['EXG_CD', 'EXG_ACRONYM']
]
quandl_cmt_mas_df = pd.merge(
    quandl_cmt_df, exc_unique_one_cme,
    left_on=['Source'], right_on=['EXG_ACRONYM'],
    how='inner',
)

quandl_cmt_mas_df = quandl_cmt_mas_df[['CMT_NM', 'EXG_CD', 'ITEM_CD']]
quandl_cmt_mas_df['USE_YN'] = 'Y'
quandl_cmt_mas_df['PRV_NM'] = 'QUANDL'
cmt_mas_df = quandl_cmt_mas_df
cmt_mas_df['ITEM_NM'] = cmt_mas_df['CMT_NM']
cmt_mas_df['CLS_CD'] = 'CMT'
cmt_mas_df

# SYMBOL: Yahoo - OPTIONINDEX
yahoo_optionindex_list = [
    ['US', 'Chicago CBOE Volatility Index', '^VIX'],
]
yahoo_futureindex_list = [
    ['US', 'S&P 500 Future Index TR', '^SP500FTR'],
]
yahoo_ecoindex_df = pd.DataFrame(
    yahoo_optionindex_list + yahoo_futureindex_list,
    columns=['CTRY_CD', 'ECX_NM', 'ITEM_CD'],
)
yahoo_ecoindex_df['PRV_NM'] = 'YAHOO'
yahoo_ecoindex_df['USE_YN'] = 'Y'

# SYMBOL: Quandl - OPTIONINDEX
quandl_optionindex_list = [
    ['US', 'US Long-Short Constant Maturity Spread', 'FRED/T10Y2Y'],
    ['US', 'TED Spread', 'FRED/TEDRATE'],
    ['US', 'US High Yield Corporate Bond Index Option-Adjusted Spread', 'ML/HYOAS'],
    ['US', 'CDSD (Credit Default Swap Data)', 'CFIS/CDSD'],
    ['US', 'Swap Curve Data', 'CFIS/SCD'],
]

# SYMBOL: Quandl - ECONOMICALINDEX
quandl_ecx_list = [
    ['US', 'ISM Manufacturing PMI', 'FRED/NAPM'],
    ['US', 'PMI Composite Index', 'ISM/MAN_PMI'],
    ['CN', 'Caixin Manufacturing PMI', 'SGE/CHNMPMI'],
    ['CN', 'Caixin Services PMI', 'SGE/CHNSPMI'],
]
quandl_ecoindex_df = pd.DataFrame(
    quandl_optionindex_list + quandl_ecx_list,
    columns=['CTRY_CD', 'ECX_NM', 'ITEM_CD'],
)
quandl_ecoindex_df['PRV_NM'] = 'QUANDL'
quandl_ecoindex_df['USE_YN'] = 'Y'
ecoindex_mas_df = pd.concat(
    [yahoo_ecoindex_df, quandl_ecoindex_df],
    ignore_index=True,
    sort=True,
)
ecoindex_mas_df['ITEM_NM'] = ecoindex_mas_df['ECX_NM']
ecoindex_mas_df['CLS_CD'] = 'ECX'


item_mas_df_list = [
    stockindex_df, fx_mas_df, gbd_yc_mas_df, cmt_mas_df, ecoindex_mas_df
]

item_mas_cols = ['CLS_CD', 'PRV_NM', 'ITEM_CD', 'ITEM_NM', 'USE_YN']
item_mas_concat_df = pd.concat(
    [df[item_mas_cols] for df in item_mas_df_list],
    ignore_index=True,
    sort=True,
)



get_column_str = f"""
SHOW columns FROM `finance_db`.`{TABLE_NM}`
;
"""

prv_df = udb.from_mysql(
    """
    SELECT
         PRV_ID
        ,PRV_NM
    FROM
        `finance_db`.`PROVIDER_MAS`
    ;
    """,
    h='35.188.205.252', port=3306, db='finance_db', u='mas', p='mas'
)
item_mas_df = pd.merge(
    prv_df, item_mas_concat_df,
    on=['PRV_NM'],
)
additional_cols = list(set(col_df['Field']).difference(item_mas_df.columns))
item_mas_new_rows = pd.concat(
    [item_mas_df, pd.DataFrame(columns=additional_cols)],
    ignore_index=True,
    sort=True,
)[col_df['Field'].values]

udb.insert_mysql(
    item_mas_new_rows, h='35.188.205.252', port=3306, u='mas', p='mas',
    db='finance_db', table=TABLE_NM, logging=False,
)

# `FX_MAS` -------------------------------------------------------------------

TABLE_NM = 'FX_MAS'
CLS_CD = 'FRX'

get_column_str = f"""
SHOW columns FROM `finance_db`.`{TABLE_NM}`
;
"""

col_df = udb.from_mysql(
    get_column_str,
    h='35.188.205.252', port=3306, db='finance_db', u='mas', p='mas'
)

item_mas_q = udb.from_mysql(
    f"""
    SELECT
         ITEM_ID
        ,ITEM_CD
    FROM
        `finance_db`.`ITEM_MAS`
    WHERE
        CLS_CD = '{CLS_CD}'
    AND USE_YN = 'Y'
    ;
    """,
    h='35.188.205.252', port=3306, db='finance_db', u='mas', p='mas'
)
joined = pd.merge(
    item_mas_q, fx_mas_df,
    on=['ITEM_CD'],
    how='inner',
)


fx_mas_new_rows = pd.merge(
    currency_rows, joined[joined['USE_YN'] == 'Y'],
    on=['CUR_CD'],
    how='inner',
)
fx_mas_new_rows['FX_DESC'] = None
fx_mas_new_rows = fx_mas_new_rows[col_df['Field'].values]

udb.insert_mysql(
    fx_mas_new_rows, h='35.188.205.252', port=3306, u='mas', p='mas',
    db='finance_db', table=TABLE_NM, logging=False,
)


# `GOVBOND_MAS` --------------------------------------------------------------

TABLE_NM = 'GOVBOND_MAS'
CLS_CD = 'BND'

get_column_str = f"""
SHOW columns FROM `finance_db`.`{TABLE_NM}`
;
"""

col_df = udb.from_mysql(
    get_column_str,
    h='35.188.205.252', port=3306, db='finance_db', u='mas', p='mas'
)

item_mas_q = udb.from_mysql(
    f"""
    SELECT
         ITEM_ID
        ,ITEM_CD
    FROM
        `finance_db`.`ITEM_MAS`
    WHERE
        CLS_CD = '{CLS_CD}'
    AND USE_YN = 'Y'
    ;
    """,
    h='35.188.205.252', port=3306, db='finance_db', u='mas', p='mas'
)
item_joined = pd.merge(
    item_mas_q, gbd_yc_mas_df,
    on=['ITEM_CD'],
    how='inner',
)
ctry_joined = pd.merge(
    item_joined, ctry_new_rows,
    on=['CTRY_CD', 'CTRY_CD3'],
    how='inner',
)
ctry_joined['GBD_ID'] = None
ctry_joined['GBD_DESC'] = None
gbc_mas_new_rows = ctry_joined.loc[
    ctry_joined['USE_YN'] == 'Y', col_df['Field'].values
]

gbc_mas_new_rows

udb.insert_mysql(
    gbc_mas_new_rows, h='35.188.205.252', port=3306, u='mas', p='mas',
    db='finance_db', table=TABLE_NM, logging=False,
)

# `STOCKINDEX_MAS` -----------------------------------------------------------

TABLE_NM = 'STOCKINDEX_MAS'
CLS_CD = 'STX'

get_column_str = f"""
SHOW columns FROM `finance_db`.`{TABLE_NM}`
;
"""

col_df = udb.from_mysql(
    get_column_str,
    h='35.188.205.252', port=3306, db='finance_db', u='mas', p='mas'
)

item_mas_q = udb.from_mysql(
    f"""
    SELECT
         ITEM_ID
        ,ITEM_CD
    FROM
        `finance_db`.`ITEM_MAS`
    WHERE
        CLS_CD = '{CLS_CD}'
    AND USE_YN = 'Y'
    ;
    """,
    h='35.188.205.252', port=3306, db='finance_db', u='mas', p='mas'
)
item_joined = pd.merge(
    item_mas_q, stockindex_df,
    on=['ITEM_CD'],
    how='inner',
)

exc_joined = pd.merge(
    item_joined, exc_new_rows,
    on=['CTRY_CD', 'EXG_CD'],
    how='inner',
)
set(col_df['Field'].values).difference(exc_joined.columns)
exc_joined['STX_ID'] = None
exc_joined['STX_DESC'] = None
exc_joined['UPDATE_FREQ'] = None
stx_mas_new_rows = exc_joined.loc[
    exc_joined['USE_YN'] == 'Y', col_df['Field'].values
].drop_duplicates()

udb.insert_mysql(
    stx_mas_new_rows, h='35.188.205.252', port=3306, u='mas', p='mas',
    db='finance_db', table=TABLE_NM, logging=False,
)


# `COMMODITY_MAS` ------------------------------------------------------------

TABLE_NM = 'COMMODITY_MAS'
CLS_CD = 'CMT'

get_column_str = f"""
SHOW columns FROM `finance_db`.`{TABLE_NM}`
;
"""

col_df = udb.from_mysql(
    get_column_str,
    h='35.188.205.252', port=3306, db='finance_db', u='mas', p='mas'
)

item_mas_q = udb.from_mysql(
    f"""
    SELECT
         ITEM_ID
        ,ITEM_CD
    FROM
        `finance_db`.`ITEM_MAS`
    WHERE
        CLS_CD = '{CLS_CD}'
    AND USE_YN = 'Y'
    ;
    """,
    h='35.188.205.252', port=3306, db='finance_db', u='mas', p='mas'
)
item_joined = pd.merge(
    item_mas_q, cmt_mas_df,
    on=['ITEM_CD'],
    how='inner',
)

cmt_joined = pd.merge(
    item_joined, exc_new_rows,
    on=['EXG_CD'],
    how='inner',
)
set(col_df['Field'].values).difference(cmt_joined.columns)
cmt_joined['CMT_ID'] = None
cmt_joined['CMT_DESC'] = None
cmt_joined['UPDATE_FREQ'] = None
cmt_mas_new_rows = cmt_joined.loc[
    cmt_joined['USE_YN'] == 'Y', col_df['Field'].values
].drop_duplicates()


udb.insert_mysql(
    cmt_mas_new_rows, h='35.188.205.252', port=3306, u='mas', p='mas',
    db='finance_db', table=TABLE_NM, logging=False,
)

cmt_mas_new_rows
item_mas_df_list = [
    stockindex_df, fx_mas_df, gbd_yc_mas_df, cmt_mas_df, ecoindex_mas_df
]
# `ECONOMICALINDEX_MAS` ------------------------------------------------------

TABLE_NM = 'ECONOMICALINDEX_MAS'
CLS_CD = 'ECX'

get_column_str = f"""
SHOW columns FROM `finance_db`.`{TABLE_NM}`
;
"""

col_df = udb.from_mysql(
    get_column_str,
    h='35.188.205.252', port=3306, db='finance_db', u='mas', p='mas'
)

item_mas_q = udb.from_mysql(
    f"""
    SELECT
         ITEM_ID
        ,ITEM_CD
    FROM
        `finance_db`.`ITEM_MAS`
    WHERE
        CLS_CD = '{CLS_CD}'
    AND USE_YN = 'Y'
    ;
    """,
    h='35.188.205.252', port=3306, db='finance_db', u='mas', p='mas'
)
item_joined = pd.merge(
    item_mas_q, ecoindex_mas_df,
    on=['ITEM_CD'],
    how='inner',
)
ctry_mas_tmp = ctry_final_rows[ctry_final_rows['CUR_CD'] != 'USN']
ecoindex_joined = pd.merge(
    item_joined, ctry_mas_tmp,
    on=['CTRY_CD'],
    how='inner',
)
set(col_df['Field'].values).difference(ecoindex_joined.columns)
ecoindex_joined['ECX_ID'] = None
ecoindex_joined['ECX_DESC'] = None
# ecoindex_joined['UPDATE_FREQ'] = None
ecoindex_mas_new_rows = ecoindex_joined.loc[
    ecoindex_joined['USE_YN'] == 'Y', col_df['Field'].values
].drop_duplicates()


udb.insert_mysql(
    ecoindex_mas_new_rows, h='35.188.205.252', port=3306, u='mas', p='mas',
    db='finance_db', table=TABLE_NM, logging=False,
)

# `RAW` ----------------------------------------------------------------------

import pandas_datareader as pdr
import datetime as dt

pdr.get_data_google('KRX:KOSPI', dt.datetime(2010, 1, 1), dt.datetime(2010, 12, 31))
pdr.data.DataReader('KRX:KOSPI', 'google', dt.datetime(2010, 1, 1), dt.datetime(2010, 12, 31))

jj = 'http://finance.yahoo.com/webservice/v1/symbols/allcurrencies/quote?format=json'

with urllib.request.urlopen(jj) as resp:
    jfile = resp.read()

jfile[:2]
