/*
 * Copyright (C) 2015 Jasbir Matharu
 * Copyright (C) 2008-2014 Freescale Semiconductor, Inc. All Rights Reserved.
 *
 * The code contained herein is licensed under the GNU General Public
 * License. You may obtain a copy of the GNU General Public License
 * Version 2 or later at the following locations:
 *
 * http://www.opensource.org/licenses/gpl-license.html
 * http://www.gnu.org/copyleft/gpl.html
 */

#include <linux/module.h>
#include <linux/of_platform.h>
#include <sound/soc.h>

#include "imx-audmux.h"

static int imx_audmux_config(int slave, int master)
{
	unsigned int ptcr, pdcr;
	slave = slave - 1;
	master = master - 1;

	ptcr = IMX_AUDMUX_V2_PTCR_SYN |
		IMX_AUDMUX_V2_PTCR_TFSDIR |
		IMX_AUDMUX_V2_PTCR_TFSEL(slave) |
		IMX_AUDMUX_V2_PTCR_TCLKDIR |
		IMX_AUDMUX_V2_PTCR_TCSEL(slave);
	pdcr = IMX_AUDMUX_V2_PDCR_RXDSEL(slave);
	imx_audmux_v2_configure_port(master, ptcr, pdcr);

	/*
	 * According to RM, RCLKDIR and SYN should not be changed at same time.
	 * So separate to two step for configuring this port.
	 */
	ptcr |= IMX_AUDMUX_V2_PTCR_RFSDIR |
		IMX_AUDMUX_V2_PTCR_RFSEL(slave) |
		IMX_AUDMUX_V2_PTCR_RCLKDIR |
		IMX_AUDMUX_V2_PTCR_RCSEL(slave);
	imx_audmux_v2_configure_port(master, ptcr, pdcr);

	ptcr = IMX_AUDMUX_V2_PTCR_SYN;
	pdcr = IMX_AUDMUX_V2_PDCR_RXDSEL(master);
	imx_audmux_v2_configure_port(slave, ptcr, pdcr);

	return 0;
}

static int imx_tda19988_hw_params(struct snd_pcm_substream *substream,
		struct snd_pcm_hw_params *params)
{
	struct snd_soc_pcm_runtime *rtd = substream->private_data;
	struct snd_soc_dai *cpu_dai = rtd->cpu_dai;
	int ret = 0;

	/* set DAI configuration */
	ret = snd_soc_dai_set_fmt(cpu_dai, SND_SOC_DAIFMT_I2S
			| SND_SOC_DAIFMT_NB_NF | SND_SOC_DAIFMT_CBS_CFS);
	if (ret) {
		dev_err(cpu_dai->dev, "failed to set dai fmt\n");
		return ret;
	}
	
	return ret;
}

static struct snd_soc_ops imx_tda19988_ops = {
	.hw_params = imx_tda19988_hw_params,
};

static struct snd_soc_dai_link imx_dai = {
	.name = "imx-tda19988",
	.stream_name = "imx-tda19988",
	.codec_dai_name = "tda19988-codec",
	.ops = &imx_tda19988_ops,
};

static struct snd_soc_card snd_soc_card_imx_3stack = {
	.name = "imx-audio-tda19988",
	.dai_link = &imx_dai,
	.num_links = 1,
};

static int imx_tda19988_probe(struct platform_device *pdev)
{
	struct snd_soc_card *card = &snd_soc_card_imx_3stack;
	struct device_node *ssi_np, *np = pdev->dev.of_node;
	struct platform_device *ssi_pdev;
	struct device_node *codec_np;
	int int_port, ext_port, ret;

	ret = of_property_read_u32(np, "mux-int-port", &int_port);
	if (ret) {
		dev_err(&pdev->dev, "mux-int-port missing or invalid\n");
		return ret;
	}

	ret = of_property_read_u32(np, "mux-ext-port", &ext_port);
	if (ret) {
		dev_err(&pdev->dev, "mux-ext-port missing or invalid\n");
		return ret;
	}

	imx_audmux_config(int_port, ext_port);

	ssi_np = of_parse_phandle(pdev->dev.of_node, "ssi-controller", 0);
	if (!ssi_np) {
		dev_err(&pdev->dev, "phandle missing or invalid\n");
		return -EINVAL;
	}

	ssi_pdev = of_find_device_by_node(ssi_np);
	if (!ssi_pdev) {
		dev_err(&pdev->dev, "failed to find SSI platform device\n");
		ret = -EINVAL;
		goto end;
	}

	codec_np = of_parse_phandle(pdev->dev.of_node, "audio-codec", 0);
	if (!codec_np) {
		dev_err(&pdev->dev, "phandle missing or invalid\n");
		ret = -EINVAL;
		goto end;
	}

	card->dev = &pdev->dev;
	card->dai_link->cpu_dai_name = dev_name(&ssi_pdev->dev);
	card->dai_link->platform_of_node = ssi_np;
	card->dai_link->codec_of_node = codec_np;

	platform_set_drvdata(pdev, card);

	ret = snd_soc_register_card(card);
	if (ret)
		dev_err(&pdev->dev, "Failed to register card: %d\n", ret);

end:
	if (ssi_np)
		of_node_put(ssi_np);
	if (codec_np)
		of_node_put(codec_np);

	return ret;
}

static int imx_tda19988_remove(struct platform_device *pdev)
{
	struct snd_soc_card *card = &snd_soc_card_imx_3stack;

	snd_soc_unregister_card(card);

	return 0;
}

static const struct of_device_id imx_tda19988_dt_ids[] = {
	{ .compatible = "udoo,imx-audio-tda19988", },
	{ /* sentinel */ }
};
MODULE_DEVICE_TABLE(of, imx_tda19988_dt_ids);

static struct platform_driver imx_tda19988_driver = {
	.driver = {
		.name = "imx-tda19988",
		.owner = THIS_MODULE,
		.pm = &snd_soc_pm_ops,
		.of_match_table = imx_tda19988_dt_ids,
	},
	.probe = imx_tda19988_probe,
	.remove = imx_tda19988_remove,
};

module_platform_driver(imx_tda19988_driver);

/* Module information */
MODULE_DESCRIPTION("ALSA SoC i.MX for TDA19988");
MODULE_AUTHOR("Jasbir Matharu");
MODULE_LICENSE("GPL");
MODULE_ALIAS("platform:imx-tda19988");
