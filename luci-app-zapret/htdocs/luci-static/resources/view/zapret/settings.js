'use strict';
'require fs';
'require form';
'require tools.widgets as widgets';
'require uci';
'require ui';
'require view';
'require view.zapret.tools as tools';

document.head.appendChild(E('link', {
    rel: 'stylesheet',
    href: L.resource('view/zapret/styles.css')
}));

return view.extend({
    svc_info: null,

    load: function()
    {
        return tools.baseLoad(this, (data) => {
            //console.log('SYS FEATURES: '+JSON.stringify(data.sys_feat));
            tools.load_feat_env();
            return data;
        });
    },

    render: function(data)
    {
        if (!data) {
            return;
        }
        this.svc_info = data.svc_info;
        tools.execDefferedAction(this.svc_info);

        let m, s, o, tabname;

        m = new form.Map(tools.appName, tools.AppName + ' - ' + _('Settings'));

        s = m.section(form.NamedSection, 'config');
        s.anonymous = true;
        s.addremove = false;

        /* NFQWS_OPT_DESYNC tab */

        tabname = 'nfqws_params';
        if (tools.appName == 'zapret2') {
            s.tab(tabname, _('NFQWS2 options'));
        } else {
            s.tab(tabname, _('NFQWS options'));
        }

        let add_delim = function(sec, url = null) {
            let o = sec.taboption(tabname, form.DummyValue, '_hr');
            o.rawhtml = true;
            o.default = '<hr style="width: 620px; height: 1px; margin: 1px 0 1px; border-top: 1px solid;">';
            if (url) {
                o.default += '<br/>' + _('Help') + ': <a target=_blank href=%s>%s</a>'.format(url);
            }
        };

        let add_param = function(sec, param, locname = null, rows = 10, multiline = false) {
            if (!locname)
                locname = param;
            let btn = sec.taboption(tabname, form.Button, '_' + param + '_btn', locname);
            btn.inputtitle = _('Edit');
            btn.inputstyle = 'edit btn';
            let val = sec.taboption(tabname, form.TextValue, '_' + param);
            val.readonly = true;
            val.rows = rows + 5;
            val.wrap = false;
            val.cfgvalue = function(section_id) {
                let value = uci.get(tools.appName, section_id, param);
                if (value == null) {
                    return "";
                }
                value = value.trim();
                if (multiline == 2) {
                    value = value.replace(/\n  --/g, "\n--");
                    value = value.replace(/\n --/g, "\n--");
                    value = value.replace(/ --/g, "\n--");
                }
                return value;
            };
            val.validate = function(section_id, value) {
                return true;
            };
            let desc = locname;
            if (multiline == 2) {
                desc += '<br/>' + _('Example') + ': <a target=_blank href=%s>%s</a>'.format(tools.nfqws_opt_url);
            }
            btn.onclick = () => new tools.longstrEditDialog({
                cfgsec: 'config',
                cfgparam: param,
                title: param,
                desc: desc,
                rows: rows,
                multiline: multiline,
            }).show();
        };

        if (tools.appName == 'zapret2') {
            o = s.taboption(tabname, form.Flag, 'NFQWS2_ENABLE', _('NFQWS2_ENABLE'));
        } else {
            o = s.taboption(tabname, form.Flag, 'NFQWS_ENABLE', _('NFQWS_ENABLE'));
        }
        o.rmempty = false;
        o.default = 1;

        o = s.taboption(tabname, form.ListValue, 'SNI_MODE', _('SNI Configuration'));
        o.value('smart_unli', 'Smart Unli Data');
        o.value('custom', 'Custom');
        o.default = 'smart_unli';

        o = s.taboption(tabname, form.Value, 'CUSTOM_SNI', _('Custom SNI'));
        o.depends('SNI_MODE', 'custom');
        o.rmempty = true;
        o.default = 'opensignal.com';

        o = s.taboption(tabname, form.Flag, 'BLOCK_QUIC', _('Block UDP 443 (Disable QUIC)'));
        o.rmempty = false;
        o.default = 1;
        
        /* Bandwidth Limiter tab */

        tabname = 'bandwidth_limiter'; 
        s.tab(tabname, _('Bandwidth Limiter'));

        o = s.taboption(tabname, form.Flag, 'QOS_ENABLE', _('Enable Speed Limit'));
        o.rmempty = false;
        o.default = 0;

        o = s.taboption(tabname, form.Value, 'QOS_DOWNLOAD', _('Download Speed (Mbps)'));
        o.depends('QOS_ENABLE', '1');
        o.rmempty = true;
        o.datatype = 'uinteger';
        o.default = '0';

        o = s.taboption(tabname, form.Value, 'QOS_UPLOAD', _('Upload Speed (Mbps)'));
        o.depends('QOS_ENABLE', '1');
        o.rmempty = true;
        o.datatype = 'uinteger';
        o.default = '0';
        
        let map_promise = m.render();
        map_promise.then(node => node.classList.add('fade-in'));
        return map_promise;
    },

    handleSaveApply: function(ev, mode)
    {
        return this.handleSave(ev).then(() => {
            let apply_exec = tools.checkUnsavedChanges();
            if (apply_exec) {
                ui.changes.apply(mode == '0');
                tools.setDefferedAction('restart', this.svc_info);
            } else {
                if (this.svc_info?.dmn.inited) {
                    tools.serviceActionEx('restart');
                }
            }
        });
    },
});
