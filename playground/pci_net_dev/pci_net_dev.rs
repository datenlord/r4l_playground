// SPDX-License-Identifier: GPL-2.0

//! Rust for linux e1000 driver demo

#![allow(unused)]


use kernel::pci::Resource;
use kernel::prelude::*;
use kernel::{pci, device, driver, net, dma, c_str};
use kernel::device::RawDevice;

pub(crate) const E1000_VENDER_ID:u32 = 0x8086;
pub(crate) const E1000_DEVICE_ID:u32 = 0x100E;

module! {
    type: E1000KernelMod,
    name: "r4l_e1000_demo",
    author: "Myrfy001",
    description: "Rust for linux e1000 driver demo",
    license: "GPL",
}

/// the private data for the adapter
struct E1000DrvPrvData {
    _netdev_reg: net::Registration<NetDevice>,
}

impl driver::DeviceRemoval for E1000DrvPrvData {
    fn device_remove(&self) {
        pr_info!("Rust for linux e1000 driver demo (device_remove)\n");
    }
}


struct E1000Drv {}

impl pci::Driver for E1000Drv {

    // The Box type has implemented PointerWrapper trait.
    type Data = Box<E1000DrvPrvData>;

    kernel::define_pci_id_table! {(), [
        (pci::DeviceId::new(E1000_VENDER_ID, E1000_DEVICE_ID), None),
    ]}

    fn probe(dev: &mut pci::Device, id: core::option::Option<&Self::IdInfo>) -> Result<Self::Data> {
        pr_info!("Rust for linux e1000 driver demo (probe): {:?}\n", id);

        let mut netdev_reg = net::Registration::<NetDevice>::try_new(dev)?;
        netdev_reg.register(Box::try_new(NetDevicePrvData{})?)?;

        Ok(Box::try_new(
            E1000DrvPrvData{
                // Must hold this registration, or the device will be removed.
                _netdev_reg: netdev_reg,
            }
        )?)
    }

    fn remove(data: &Self::Data) {
        pr_info!("Rust for linux e1000 driver demo (remove)\n");
    }
}
struct E1000KernelMod {
    pci_dev: Pin<Box<driver::Registration::<pci::Adapter<E1000Drv>>>>,
}

impl kernel::Module for E1000KernelMod {
    fn init(name: &'static CStr, module: &'static ThisModule) -> Result<Self> {
        pr_info!("Rust for linux e1000 driver demo (init)\n");
        let pci_dev = driver::Registration::<pci::Adapter<E1000Drv>>::new_pinned(name, module)?;

        // we need to store `d` into the module struct, otherwise it will be dropped, which 
        // means the PCI driver will be removed.
        Ok(E1000KernelMod {pci_dev})
    }
}

impl Drop for E1000KernelMod {
    fn drop(&mut self) {
        pr_info!("Rust for linux e1000 driver demo (exit)\n");
    }
}


/// The private data for this driver
struct NetDevicePrvData {}

// TODO not sure why it is safe to do this.
unsafe impl Send for NetDevicePrvData {}
unsafe impl Sync for NetDevicePrvData {}

/// Represent the network device
struct NetDevice {}


#[vtable]
impl net::DeviceOperations for NetDevice {
    
    type Data = Box<NetDevicePrvData>;

    fn open(dev: &net::Device, data: &NetDevicePrvData) -> Result {
        pr_info!("Rust for linux e1000 driver demo (net device open)\n");
        Ok(())
    }

    fn stop(_dev: &net::Device, _data: &NetDevicePrvData) -> Result {
        pr_info!("Rust for linux e1000 driver demo (net device stop)\n");
        Ok(())
    }

    fn start_xmit(skb: &net::SkBuff, dev: &net::Device, data: &NetDevicePrvData) -> net::NetdevTx {
        pr_info!("Rust for linux e1000 driver demo (net device start_xmit)");
        net::NetdevTx::Ok
    }

    fn get_stats64(_netdev: &net::Device, _data: &NetDevicePrvData, stats: &mut net::RtnlLinkStats64) {
        pr_info!("Rust for linux e1000 driver demo (net device get_stats64)\n");
        // TODO not implemented.
        stats.set_rx_bytes(0);
        stats.set_rx_packets(0);
        stats.set_tx_bytes(0);
        stats.set_tx_packets(0);
    }
}