import dataPreferences from '@ohos.data.preferences';
import { preferences, ValueType } from '@kit.ArkData';
import { BusinessError } from '@kit.BasicServicesKit';

class PreferencesManager {
  private preferences: dataPreferences.Preferences | null = null;

  async init(context:  Context, name: string) {
    let options: dataPreferences.Options = { name };
    this.preferences = await dataPreferences.getPreferences(context, options);
  }

  getPreferences() {
    return this.preferences;
  }

  async get(key: string, defaultValue: ValueType) {
    if (this.preferences) {
      return  this.preferences.get(key, defaultValue);
    } else {
      console.error('Preferences instance is not initialized');
      return defaultValue;
    }
  }

  // 存储键值对
  async put(key: string, value: ValueType) {
    if (this.preferences) {
      return this.preferences.put(key, value,(err: BusinessError) => {
        if (err) {
          console.error("Failed to put value of 'startup'. code =" + err.code + ", message =" + err.message);
          return;
        }
        console.info("Succeeded in putting value of 'startup'.");
      });
    } else {
      console.error('Preferences instance is not initialized');
    }
  }

  // 将数据持久化到文件
  async flush() {
    if (this.preferences) {
      return this.preferences.flush((err: BusinessError) => {
        if (err) {
          console.error("Failed to flush. code =" + err.code + ", message =" + err.message);
          return;
        }
        console.info("Succeeded in flushing.");
      });
    } else {
      console.error('Preferences instance is not initialized');
    }
  }
}

export const preferencesManager = new PreferencesManager();