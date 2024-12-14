import { relationalStore } from "@kit.ArkData";


export const STORE_CONFIG:relationalStore.StoreConfig = {
  name: 'MusicHistory.db',
  securityLevel: relationalStore.SecurityLevel.S1,
  encrypt: false
}

export const SQL_TABLE_MUSIC_NAME = "MUSIC"

export const SQL_TABLE_MUSIC_ROWS_LIMIT = 100

export const SQL_CREATE_TABLE_MUSIC: string = `CREATE TABLE IF NOT EXISTS ${SQL_TABLE_MUSIC_NAME} (ID INTEGER PRIMARY KEY AUTOINCREMENT, MID INTEGER, MUSICNAME VARCHAR(255), SINGER VARCHAR(255), MUSICURL TEXT, IMAGEURL TEXT);`

export const SQL_DELETE_NOT_LAST_ROWS_TABLE_MUSIC: string = `DELETE FROM ${SQL_TABLE_MUSIC_NAME}
WHERE ID NOT IN (
  SELECT ID FROM (
    SELECT ID
    FROM ${SQL_TABLE_MUSIC_NAME}
    ORDER BY ID DESC
    LIMIT ${SQL_TABLE_MUSIC_ROWS_LIMIT}
  ) AS T
);`