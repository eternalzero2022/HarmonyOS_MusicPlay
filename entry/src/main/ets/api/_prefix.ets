export const API_MODULE = 'http://172.29.4.77:8080/api'; //由于baseURL不知道为什么突然失效了，直接硬编码地址了

//export const API_MODULE = 'http://127.0.0.1:8080/api';
//export const API_MODULE = '/api';
export const TEST_MODULE = `${API_MODULE}/test`;

export const MUSIC_FILE_MODULE = `${API_MODULE}/musicfile`;

export const MUSIC_MODULE = `${API_MODULE}/music`;

export const IMAGE_MODULE = `${API_MODULE}/images`;

export const USER_MODULE = `${API_MODULE}/user`;

export const REGISTER_MODULE = `${USER_MODULE}/register`;

export const USERLOGIN_MODULE = `${USER_MODULE}/userlogin`;

export const ADMINLOGIN_MODULE = `${USER_MODULE}/adminlogin`;

export const PLAYLIST_MODULE = `${API_MODULE}/playlist`;

export const COMMENT_MODULE = `${API_MODULE}/comment`;

