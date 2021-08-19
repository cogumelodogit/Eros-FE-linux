import 'package:fehviewer/common/controller/webdav_controller.dart';
import 'package:fehviewer/common/global.dart';
import 'package:fehviewer/common/service/theme_service.dart';
import 'package:fehviewer/pages/setting/setting_base.dart';
import 'package:fehviewer/utils/logger.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:line_icons/line_icons.dart';
import 'package:fehviewer/generated/l10n.dart';
import 'package:fehviewer/models/base/eh_models.dart';
import 'package:webdav_client/webdav_client.dart' as webdav;

class WebDavSetting extends GetView<WebdavController> {
  const WebDavSetting({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final String _title = 'WebDAV';
    return CupertinoPageScaffold(
      backgroundColor: !ehTheme.isDarkMode
          ? CupertinoColors.secondarySystemBackground
          : null,
      navigationBar: CupertinoNavigationBar(
        padding: const EdgeInsetsDirectional.only(end: 5),
        middle: Text(_title),
        trailing: _buildListBtns(context),
      ),
      child: GetBuilder<WebdavController>(
        builder: (logic) {
          return SafeArea(
            child: logic.validAccount ? const WebDavSettingView() : Container(),
          );
        },
      ),
    );
  }

  Widget _buildListBtns(BuildContext context) {
    return controller.validAccount
        ? const SizedBox.shrink()
        : CupertinoButton(
            minSize: 40,
            padding: const EdgeInsets.all(0),
            child: const Icon(
              LineIcons.alternateSignIn,
              size: 28,
            ),
            onPressed: () {
              showWebDAVLogin(context);
            });
  }
}

class WebDavSettingView extends GetView<WebdavController> {
  const WebDavSettingView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SelectorSettingItem(
          title: L10n.of(context).webdav_Account,
          desc: controller.webdavProfile.user,
          onTap: () {
            showCupertinoDialog(
              context: context,
              builder: (context) {
                return CupertinoAlertDialog(
                  title: Text('Logout?'),
                  actions: <Widget>[
                    CupertinoDialogAction(
                      child: Text(L10n.of(context).cancel),
                      onPressed: () {
                        Get.back();
                      },
                    ),
                    CupertinoDialogAction(
                      child: Text(L10n.of(context).ok),
                      onPressed: () async {
                        Global.profile = Global.profile
                            .copyWith(webdav: const WebdavProfile(url: ''));
                        Global.saveProfile();
                        Get.replace(WebdavProfile(url: ''));
                        controller.close();
                        Get.back();
                      },
                    ),
                  ],
                );
              },
            );
          },
          hideLine: true,
        ),
        Container(height: 38),
        TextSwitchItem(
          L10n.of(context).sync_history,
          intValue: controller.syncHistory,
          onChanged: (val) {
            controller.syncHistory = val;
          },
        ),
        TextSwitchItem(
          L10n.of(context).sync_read_progress,
          intValue: controller.syncReadProgress,
          onChanged: (val) {
            controller.syncReadProgress = val;
          },
        ),
      ],
    );
  }
}

Future<void> showWebDAVLogin(BuildContext context) async {
  final TextEditingController _urlController = TextEditingController();
  final TextEditingController _unameController = TextEditingController();
  final TextEditingController _pwdController = TextEditingController();
  final FocusNode _nodePwd = FocusNode();
  final FocusNode _nodeUname = FocusNode();
  return showCupertinoDialog<void>(
    context: context,
    builder: (BuildContext context) {
      return CupertinoAlertDialog(
        content: Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              CupertinoTextField(
                decoration: BoxDecoration(
                  color: ehTheme.textFieldBackgroundColor,
                  borderRadius: const BorderRadius.all(Radius.circular(8.0)),
                ),
                clearButtonMode: OverlayVisibilityMode.editing,
                controller: _urlController,
                placeholder: 'Url',
                autofocus: true,
                onEditingComplete: () {
                  // 点击键盘完成
                  FocusScope.of(context).requestFocus(_nodeUname);
                },
              ),
              Container(
                height: 10,
              ),
              CupertinoTextField(
                decoration: BoxDecoration(
                  color: ehTheme.textFieldBackgroundColor,
                  borderRadius: const BorderRadius.all(Radius.circular(8.0)),
                ),
                clearButtonMode: OverlayVisibilityMode.editing,
                controller: _unameController,
                placeholder: 'User',
                focusNode: _nodeUname,
                onEditingComplete: () {
                  // 点击键盘完成
                  FocusScope.of(context).requestFocus(_nodePwd);
                },
              ),
              Container(
                height: 10,
              ),
              GetBuilder<WebdavController>(builder: (logic) {
                return CupertinoTextField(
                  decoration: BoxDecoration(
                    color: ehTheme.textFieldBackgroundColor,
                    borderRadius: const BorderRadius.all(Radius.circular(8.0)),
                  ),
                  clearButtonMode: OverlayVisibilityMode.editing,
                  controller: _pwdController,
                  placeholder: 'Password',
                  focusNode: _nodePwd,
                  obscureText: true,
                  onEditingComplete: () async {
                    // 点击键盘完成
                    final rult = await logic.addWebDAVProfile(
                      _urlController.text,
                      user: _unameController.text,
                      pwd: _pwdController.text,
                    );
                    if (rult) {
                      Get.back();
                    }
                  },
                );
              }),
            ],
          ),
        ),
        actions: <Widget>[
          CupertinoDialogAction(
            child: Text(L10n.of(context).cancel),
            onPressed: () {
              Get.back();
            },
          ),
          GetBuilder<WebdavController>(
            id: idActionLogin,
            builder: (logic) {
              return CupertinoDialogAction(
                child: logic.isLongining
                    ? const CupertinoActivityIndicator()
                    : Text(L10n.of(context).ok),
                onPressed: logic.isLongining
                    ? null
                    : () async {
                        logic.isLongining = true;
                        final rult = await logic.addWebDAVProfile(
                          _urlController.text,
                          user: _unameController.text,
                          pwd: _pwdController.text,
                        );
                        if (rult) {
                          Get.back();
                        }
                      },
              );
            },
          ),
        ],
      );
    },
  );
}
