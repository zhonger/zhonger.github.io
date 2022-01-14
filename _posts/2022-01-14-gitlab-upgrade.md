---
layout: post
title: 'Gitlab 升级那些事儿'
subtitle: '了解更加深入的 Gitlab 升级及修复'
date: 2022-01-14 11:13:00 +0900
tags: 
- Nextcloud
- Upgrade
- Fix
- 升级
- 修复
categories: [tech, webmaster]
cover: 'https://images.unsplash.com/photo-1640554518394-5c45f8f95deb?w=1600&q=900'
---

## 前言

&emsp;&emsp;Gitlab 的升级策略似乎已经在 [私有代码托管平台的搭建与运维](../docker/gitlab.html) 中解释得比较详细了，但实际上忽略了秘钥文件 /home/git/gitlab/config/secrets.yml 和 /home/git/gitlab/config/gitlab.yml 的备份。这两个文件不是在容器内的代码文件里面吗？为什么又需要备份这两个秘钥文件呢？其实为了安全性的考虑，Gitlab 自带的备份工具只会备份包括数据库、数据文件以及基本配置信息，而秘钥作为安全文件不在备份之列。这两个秘钥文件涉及到数据库中某些加密字段的加密和解密过程，如果没有这两个原始文件或者使用了新的文件，那么 Gitlab 将无法对这些数据库中已有的加密字段进行解密，从而影响到某些页面的使用，尤其是管理员界面。

## 升级及修复

### 升级

&emsp;&emsp;本次的升级及修复过程以 14.0.6 -> 14.6.1 为例。根据 Gitlab 官方给出的建议规划路线 latest 14.0.Z -> 14.1.Z -> latest 14.Y.Z 以及 [sameersbn/docker-gitlab](https://github.com/sameersbn/docker-gitlab) 所发布的容器镜像版本，可以判断出实际可行的最短升级路线为 14.0.6 -> 14.1.3 -> 14.6.1（完全逐步迭代升级路线为 14.0.6 -> 14.1.3 -> 14.2.5 -> 14.3.3 -> 14.4.4 -> 14.5.2 -> 14.6.1）。这里值得注意的是，从 14.1.0 的 [版本更新说明](https://docs.gitlab.com/ee/update/#1410) 也可以看出，14.1.0 版本是一个重大更新版本，14.0.6 无法跨过 14.1.Z 版本进行更新到其他更新版本。另外，14.2.0 和 14.3.0 版本都对数据库做了微小的调整。具体升级过程可以参照 [私有代码托管平台的搭建与运维 - 边备份边升级](../docker/gitlab.html#边备份边升级)。

### 修复管理员设置 500 错误

&emsp;&emsp;前面已经提到当两个秘钥文件与加密数据库字段的密钥文件不一致时，加密字段无法被解析，从而导致在管理页面修改任何涉及到加密字段的内容都会弹出 500 错误。官方给出的解决方案是将这些加密字段都置空，加密字段无法置空的记录均删除。

#### 验证错误情况

```bash
# 验证秘钥引发的错误情况
docker exec -ti -u git gitlab_gitlab_1 bundle exec rake gitlab:doctor:secrets

# 打印信息
I, [2022-01-14T12:11:06.976367 #207818]  INFO -- : Checking encrypted values in the database
I, [2022-01-14T12:11:14.207746 #207818]  INFO -- : - Ci::InstanceVariable failures: 0
I, [2022-01-14T12:11:14.236285 #207818]  INFO -- : - Ci::PipelineScheduleVariable failures: 0
I, [2022-01-14T12:11:14.264758 #207818]  INFO -- : - Ci::Variable failures: 0
I, [2022-01-14T12:11:14.289639 #207818]  INFO -- : - Ci::GroupVariable failures: 0
I, [2022-01-14T12:11:14.311448 #207818]  INFO -- : - Ci::PipelineVariable failures: 0
I, [2022-01-14T12:11:14.330957 #207818]  INFO -- : - Ci::JobVariable failures: 0
I, [2022-01-14T12:11:14.364695 #207818]  INFO -- : - ApplicationSetting failures: 1
I, [2022-01-14T12:11:14.457574 #207818]  INFO -- : - User failures: 0
I, [2022-01-14T12:11:14.483107 #207818]  INFO -- : - Clusters::Platforms::Kubernetes failures: 0
I, [2022-01-14T12:11:14.504624 #207818]  INFO -- : - Snippet failures: 0
I, [2022-01-14T12:11:14.507763 #207818]  INFO -- : - PersonalSnippet failures: 0
I, [2022-01-14T12:11:14.510827 #207818]  INFO -- : - ProjectSnippet failures: 0
I, [2022-01-14T12:11:14.534412 #207818]  INFO -- : - Clusters::Applications::Helm failures: 0
I, [2022-01-14T12:11:14.552858 #207818]  INFO -- : - Clusters::Applications::Prometheus failures: 0
I, [2022-01-14T12:11:14.572631 #207818]  INFO -- : - AlertManagement::HttpIntegration failures: 0
I, [2022-01-14T12:11:14.591745 #207818]  INFO -- : - ProjectImportData failures: 0
I, [2022-01-14T12:11:14.612651 #207818]  INFO -- : - RemoteMirror failures: 0
I, [2022-01-14T12:11:14.634588 #207818]  INFO -- : - GrafanaIntegration failures: 0
I, [2022-01-14T12:11:14.657573 #207818]  INFO -- : - PagesDomainAcmeOrder failures: 0
I, [2022-01-14T12:11:14.678924 #207818]  INFO -- : - JiraConnectInstallation failures: 0
I, [2022-01-14T12:11:14.701446 #207818]  INFO -- : - PagesDomain failures: 0
I, [2022-01-14T12:11:14.723396 #207818]  INFO -- : - WebHook failures: 1
I, [2022-01-14T12:11:14.728267 #207818]  INFO -- : - ProjectHook failures: 1
I, [2022-01-14T12:11:14.732394 #207818]  INFO -- : - ServiceHook failures: 0
I, [2022-01-14T12:11:14.735019 #207818]  INFO -- : - SystemHook failures: 0
I, [2022-01-14T12:11:14.756876 #207818]  INFO -- : - Integrations::IssueTrackerData failures: 0
I, [2022-01-14T12:11:14.775782 #207818]  INFO -- : - Integrations::JiraTrackerData failures: 0
I, [2022-01-14T12:11:14.797853 #207818]  INFO -- : - Integrations::ZentaoTrackerData failures: 0
I, [2022-01-14T12:11:14.818263 #207818]  INFO -- : - BulkImports::Configuration failures: 0
I, [2022-01-14T12:11:14.838087 #207818]  INFO -- : - Clusters::KubernetesNamespace failures: 0
I, [2022-01-14T12:11:14.859981 #207818]  INFO -- : - Atlassian::Identity failures: 0
I, [2022-01-14T12:11:14.881123 #207818]  INFO -- : - IncidentManagement::ProjectIncidentManagementSetting failures: 0
I, [2022-01-14T12:11:14.903973 #207818]  INFO -- : - ErrorTracking::ProjectErrorTrackingSetting failures: 0
I, [2022-01-14T12:11:14.922100 #207818]  INFO -- : - Alerting::ProjectAlertingSetting failures: 0
I, [2022-01-14T12:11:14.941501 #207818]  INFO -- : - Serverless::DomainCluster failures: 0
I, [2022-01-14T12:11:14.944543 #207818]  INFO -- : - Clusters::Integrations::Prometheus failures: 0
I, [2022-01-14T12:11:14.965724 #207818]  INFO -- : - Clusters::Providers::Gcp failures: 0
I, [2022-01-14T12:11:14.985521 #207818]  INFO -- : - Clusters::Providers::Aws failures: 0
I, [2022-01-14T12:11:15.005871 #207818]  INFO -- : - Packages::Debian::ProjectDistributionKey failures: 0
I, [2022-01-14T12:11:15.025454 #207818]  INFO -- : - Packages::Debian::GroupDistributionKey failures: 0
I, [2022-01-14T12:11:15.029060 #207818]  INFO -- : - Gitlab::BackgroundMigration::BackfillJiraTrackerDeploymentType2::JiraTrackerDataTemp failures: 0
I, [2022-01-14T12:11:15.081215 #207818]  INFO -- : - Ci::Runner failures: 1
I, [2022-01-14T12:11:15.309755 #207818]  INFO -- : - Ci::Build failures: 1
I, [2022-01-14T12:11:15.449126 #207818]  INFO -- : - Group failures: 0
I, [2022-01-14T12:11:15.662949 #207818]  INFO -- : - Project failures: 0
I, [2022-01-14T12:11:15.710390 #207818]  INFO -- : - DeployToken failures: 0
I, [2022-01-14T12:11:15.740096 #207818]  INFO -- : - Clusters::AgentToken failures: 0
I, [2022-01-14T12:11:15.762011 #207818]  INFO -- : - Operations::FeatureFlagsClient failures: 0
I, [2022-01-14T12:11:15.762112 #207818]  INFO -- : Total: 5 row(s) affected
I, [2022-01-14T12:11:15.762150 #207818]  INFO -- : Done!
```
#### 连接数据库

&emsp;&emsp;以下为官方给定的在不同版本和安装方式下连接数据库的命令。由于容器 sameersbn/docker-gitlab 采用的是源码安装方式，所以采用最后一种连接方式，所以使用命令如最后所示。

```bash
# For Omnibus GitLab 14.1 and earlier:
sudo gitlab-rails dbconsole

# For Omnibus GitLab 14.2 and later:
sudo gitlab-rails dbconsole --database main

# For installations from source, GitLab 14.1 and earlier:
sudo -u git -H bundle exec rails dbconsole -e production

# For installations from source, GitLab 14.2 and later:
sudo -u git -H bundle exec rails dbconsole -e production --database main

# 容器 sameersbn/docker-gitlab 连接数据库
docker exec -ti -u git gitlab_gitlab_1 bundle exec rails dbconsole -e production --database main
```

#### 查询并重置 CI/CD 数据

```sql
--  查询所有 CI/CD 记录
SELECT * FROM public."ci_group_variables";
SELECT * FROM public."ci_variables";

-- 删除所有 CI/CD 记录
DELETE FROM ci_group_variables;
DELETE FROM ci_variables;
```

#### 清除加密 TOKEN

```sql
-- Clear project tokens
UPDATE projects SET runners_token = null, runners_token_encrypted = null;
-- Clear group tokens
UPDATE namespaces SET runners_token = null, runners_token_encrypted = null;
-- Clear instance tokens
UPDATE application_settings SET runners_registration_token_encrypted = null;
-- Clear key used for JWT authentication
-- This may break the $CI_JWT_TOKEN job variable:
-- https://gitlab.com/gitlab-org/gitlab/-/issues/325965
UPDATE application_settings SET encrypted_ci_jwt_signing_key = null;
-- Clear runner tokens
UPDATE ci_runners SET token = null, token_encrypted = null;
-- Clear build tokens
UPDATE ci_builds SET token = null, token_encrypted = null;
-- truncate web_hooks table
TRUNCATE web_hooks CASCADE;
```

#### 重新验证错误

```bash
# 验证秘钥引发的错误情况
docker exec -ti -u git gitlab_gitlab_1 bundle exec rake gitlab:doctor:secrets

# 发现所有错误均为 0 表示修复成功。可以访问管理员设置页面进行验证。
```

### 修复指标和分析 500 错误

&emsp;&emsp;指标和分析 500 错误是从升级到 14.0.5 版本之后开始出现的，主要是因为在指标和分析中新增了指向 tmpfs 的配置项 prometheus_multiproc_dir。在默认的 sameersbn/docker-gitlab 容器中还未添加这一配置项，从而导致指标和分析页面无法访问。修复方法是，在 docker-compose.yml 中添加该配置项，如下所示。

```yaml
version: '2.3'

services:
  redis:
    restart: always
    image: redis:6.2.6
    command:
    - --loglevel warning
    volumes:
    - ./redis-data:/data

  postgresql:
    restart: always
    image: sameersbn/postgresql:12-20200524
    volumes:
    - ./postgresql-data:/var/lib/postgresql
    environment:
    - DB_USER=gitlab
    - DB_PASS=password
    - DB_NAME=gitlabhq_production
    - DB_EXTENSION=pg_trgm,btree_gist

  gitlab:
    restart: always
    image: sameersbn/gitlab:14.6.1
    depends_on:
    - redis
    - postgresql
    ports:
    - "80:80"
    - "22:22"
    volumes:
    - ./gitlab-data:/home/git/data
    healthcheck:
      test: ["CMD", "/usr/local/sbin/healthcheck"]
      interval: 5m
      timeout: 10s
      retries: 3
      start_period: 5m
    environment:
    - DEBUG=false
    - prometheus_multiproc_dir=/dev/shm
    ......
```


## 参考资料

- [When the secrets file is lost](https://docs.gitlab.com/ee/raketasks/backup_restore.html#when-the-secrets-file-is-lost)
- [Storing configuration files](https://docs.gitlab.com/ee/raketasks/backup_restore.html#storing-configuration-files)
- [Metrics shared directory](https://docs.gitlab.com/ee/administration/monitoring/prometheus/gitlab_metrics.html#metrics-shared-directory)
- [Gitlab Admin 管理页面提示 500 内部错误(500 Internal error)的解决办法](https://blog.csdn.net/weixin_44295157/article/details/119618816)
- [gitlab 迁移之后 runner 报 500 解决方案----gitlab-secrets.json 忘记备份](https://blog.csdn.net/Shawn_wang_0919/article/details/115895292)
- [GitLab 备份恢复后 500 错误修复](https://lintian.co/archives/16)
- [metrics and profiling not working after upgrade to 14.0.5](https://github.com/sameersbn/docker-gitlab/issues/2387)